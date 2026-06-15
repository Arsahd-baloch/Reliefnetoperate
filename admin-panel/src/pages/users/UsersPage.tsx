import React, { useState, useMemo } from 'react';
import { Link } from 'react-router-dom';
import { Table, Tag, Button, Space, Typography, Modal, notification, Card, Tooltip, Input, Select, Row, Col } from 'antd';
import { UserDeleteOutlined, UserAddOutlined, ExclamationCircleOutlined, EyeOutlined, SearchOutlined } from '@ant-design/icons';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import axiosClient from '../../api/axiosClient';
import { API_ENDPOINTS } from '../../api/endpoints';
import type { User } from '../../types/user';
import dayjs from 'dayjs';
import { useAuthContext } from '../../auth/AuthContext.tsx';
import { unwrapResponse, normalizeUser } from '../../utils/apiNormalizer';
import { AxiosError } from 'axios';

const { Title, Text } = Typography;

const UsersPage: React.FC = () => {
  const queryClient = useQueryClient();
  const { user: currentUser } = useAuthContext();
  const [selectedRowKeys, setSelectedRowKeys] = useState<React.Key[]>([]);
  const [roleFilter, setRoleFilter] = useState<string>('ALL');
  const [searchText, setSearchText] = useState('');

  const { data, isLoading } = useQuery({
    queryKey: ['admin', 'users', 'list'],
    queryFn: async () => {
      const response = await axiosClient.get(API_ENDPOINTS.ADMIN.USERS);
      return unwrapResponse<Record<string, unknown>>(response.data, 'users').map(normalizeUser);
    }
  });

  const allUsers = data || [];

  const users = useMemo(() => {
    return allUsers.filter(u => {
      const matchesRole = roleFilter === 'ALL' || u.role === roleFilter;
      const q = searchText.toLowerCase();
      const matchesSearch = !q || u.name?.toLowerCase().includes(q) || u.email?.toLowerCase().includes(q);
      return matchesRole && matchesSearch;
    });
  }, [allUsers, roleFilter, searchText]);

  const bulkStatusMutation = useMutation({
    mutationFn: async ({ user_ids, status }: { user_ids: number[], status: string }) => {
      return axiosClient.post('/admin/users/bulk-status', { user_ids, status });
    },
    onSuccess: (data) => {
      const { success, failed } = data.data;
      notification.success({ 
        message: 'Bulk Action Complete', 
        description: `Successfully updated ${success.length} users. ${failed.length} failed.` 
      });
      setSelectedRowKeys([]);
      queryClient.invalidateQueries({ queryKey: ['admin', 'users'] });
    }
  });

  const handleBulkStatus = (status: 'ACTIVE' | 'SUSPENDED') => {
    Modal.confirm({
      title: `Bulk ${status === 'ACTIVE' ? 'Activate' : 'Suspend'}`,
      content: `Are you sure you want to ${status.toLowerCase()} ${selectedRowKeys.length} selected users?`,
      onOk: () => bulkStatusMutation.mutateAsync({ 
        user_ids: selectedRowKeys.map(k => Number(k)), 
        status 
      }),
    });
  };

  const suspendMutation = useMutation({
    mutationFn: async (id: number) => {
      return axiosClient.patch(API_ENDPOINTS.USERS.SUSPEND(id));
    },
    onSuccess: () => {
      notification.success({ message: 'User suspended' });
      queryClient.invalidateQueries({ queryKey: ['admin', 'users'] });
    },
    onError: (error: AxiosError<{ error?: string }>) => {
      notification.error({ 
        message: 'Failed to suspend user',
        description: error.response?.data?.error || 'Internal error'
      });
    }
  });

  const reactivateMutation = useMutation({
    mutationFn: async (id: number) => {
      return axiosClient.patch(API_ENDPOINTS.USERS.REACTIVATE(id));
    },
    onSuccess: () => {
      notification.success({ message: 'User reactivated' });
      queryClient.invalidateQueries({ queryKey: ['admin', 'users'] });
    },
    onError: (error: AxiosError<{ error?: string }>) => {
      notification.error({ 
        message: 'Failed to reactivate user',
        description: error.response?.data?.error || 'Internal error'
      });
    }
  });

  const handleSuspend = (user: User) => {
    if (user.role === 'ADMIN') {
      notification.warning({ message: 'Action restricted', description: 'Cannot suspend ADMIN users.' });
      return;
    }

    Modal.confirm({
      title: 'Suspend User Account',
      icon: <ExclamationCircleOutlined />,
      content: (
        <div>
          <p>Are you sure you want to suspend <strong>{user.name}</strong> ({user.email})?</p>
          <p>This user will lose all access to the platform immediately.</p>
        </div>
      ),
      okText: 'Suspend',
      okType: 'danger',
      cancelText: 'Cancel',
      onOk: () => suspendMutation.mutateAsync(user.id),
    });
  };

  const handleReactivate = (user: User) => {
    Modal.confirm({
      title: 'Reactivate User Account',
      content: `Are you sure you want to reactivate the account for ${user.name}?`,
      onOk: () => reactivateMutation.mutateAsync(user.id),
      okText: 'Reactivate',
      cancelText: 'Cancel',
    });
  };

  const getRoleColor = (role: string) => {
    switch (role) {
      case 'ADMIN': return 'red';
      case 'NGO': return 'purple';
      case 'VOLUNTEER': return 'blue';
      case 'COORDINATOR': return 'orange';
      case 'DONOR': return 'green';
      default: return 'default';
    }
  };

  const columns = [
    {
      title: 'ID',
      dataIndex: 'id',
      key: 'id',
      width: 80,
    },
    {
      title: 'Name',
      dataIndex: 'name',
      key: 'name',
      render: (text: string, record: User) => (
        <Space orientation="vertical" size={0}>
          <Typography.Text strong>{text}</Typography.Text>
          <Typography.Text type="secondary" style={{ fontSize: '12px' }}>{record.email}</Typography.Text>
        </Space>
      )
    },
    {
      title: 'Role',
      dataIndex: 'role',
      key: 'role',
      render: (role: string) => <Tag color={getRoleColor(role)}>{role}</Tag>
    },
    {
      title: 'Status',
      dataIndex: 'status',
      key: 'status',
      render: (status: string) => (
        <Tag color={status === 'ACTIVE' ? 'success' : 'error'}>
          {status}
        </Tag>
      )
    },
    {
      title: 'Joined',
      dataIndex: 'created_at',
      key: 'created_at',
      render: (date: string) => dayjs(date).format('MMM D, YYYY'),
    },
    {
      title: 'Actions',
      key: 'actions',
      render: (_: unknown, record: User) => {
        const isSelf = record.id === currentUser?.id;
        const isAdmin = record.role === 'ADMIN';
        const isSuspended = record.status === 'SUSPENDED';

        return (
          <Space>
            {record.role === 'NGO' && (
              <Link to={`/ngos/${record.id}`}>
                <Button icon={<EyeOutlined />} size="small">View NGO</Button>
              </Link>
            )}
            {isSuspended ? (
              <Button 
                icon={<UserAddOutlined />} 
                size="small" 
                type="primary"
                ghost
                onClick={() => handleReactivate(record)}
              >
                Reactivate
              </Button>
            ) : (
              <Tooltip title={isAdmin ? "Cannot suspend Admin" : ""}>
                <Button 
                  danger 
                  icon={<UserDeleteOutlined />} 
                  size="small"
                  disabled={isAdmin || isSelf}
                  onClick={() => handleSuspend(record)}
                >
                  Suspend
                </Button>
              </Tooltip>
            )}
          </Space>
        );
      },
    },
  ];

  return (
    <Card>
      <div style={{ marginBottom: 16, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <Title level={3} style={{ margin: 0 }}>User Management</Title>
        {selectedRowKeys.length > 0 && (
          <Space>
            <Text strong>{selectedRowKeys.length} selected</Text>
            <Button 
              type="primary" 
              ghost 
              onClick={() => handleBulkStatus('ACTIVE')}
              loading={bulkStatusMutation.isPending}
            >
              Bulk Activate
            </Button>
            <Button 
              danger 
              onClick={() => handleBulkStatus('SUSPENDED')}
              loading={bulkStatusMutation.isPending}
            >
              Bulk Suspend
            </Button>
          </Space>
        )}
      </div>
      <Row gutter={12} style={{ marginBottom: 16 }}>
        <Col flex="auto">
          <Input
            prefix={<SearchOutlined style={{ color: '#bfbfbf' }} />}
            placeholder="Search by name or email..."
            value={searchText}
            onChange={e => setSearchText(e.target.value)}
            allowClear
          />
        </Col>
        <Col>
          <Select
            value={roleFilter}
            onChange={setRoleFilter}
            style={{ width: 160 }}
            options={[
              { label: 'All Roles', value: 'ALL' },
              { label: 'Admin', value: 'ADMIN' },
              { label: 'NGO', value: 'NGO' },
              { label: 'Volunteer', value: 'VOLUNTEER' },
              { label: 'Coordinator', value: 'COORDINATOR' },
              { label: 'Donor', value: 'DONOR' },
            ]}
          />
        </Col>
      </Row>
      <Table
        rowSelection={{
          selectedRowKeys,
          onChange: (keys) => setSelectedRowKeys(keys),
          getCheckboxProps: (record: User) => ({
            disabled: record.id === currentUser?.id || record.role === 'ADMIN',
          }),
        }}
        columns={columns} 
        dataSource={users} 
        rowKey="id" 
        loading={isLoading}
        pagination={{ pageSize: 10 }}
      />
    </Card>
  );
};

export default UsersPage;
