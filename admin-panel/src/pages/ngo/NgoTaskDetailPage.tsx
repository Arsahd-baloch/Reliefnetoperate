import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Card, Row, Col, Typography, Tag, Divider, Spin, Alert, Button, Space, Descriptions, Modal, Select, notification } from 'antd';
import {
  ArrowLeftOutlined,
  EnvironmentOutlined,
  UserOutlined,
  HistoryOutlined,
  SendOutlined
} from '@ant-design/icons';
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import axiosClient from '../../api/axiosClient';
import dayjs from 'dayjs';
import { safeFormatCurrency } from '../../utils/apiNormalizer';

const { Title, Text, Paragraph } = Typography;

const getStatusColor = (status: string): string => {
  const map: Record<string, string> = {
    OPEN: 'blue',
    CLAIMED: 'orange',
    ASSIGNED: 'purple',
    IN_PROGRESS: 'processing',
    PARTIALLY_COMPLETED: 'gold',
    COORDINATOR_VERIFIED: 'cyan',
    PAID: 'green',
    FLAGGED: 'red',
    CANCELLED: 'default',
  };
  return map[status] ?? 'default';
};

const NgoTaskDetailPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const queryClient = useQueryClient();
  const [isAssignModalVisible, setIsAssignModalVisible] = useState(false);
  const [selectedVolunteer, setSelectedVolunteer] = useState<number | null>(null);

  const { data: task, isLoading, error } = useQuery({
    queryKey: ['ngo', 'task', id],
    queryFn: async () => {
      const response = await axiosClient.get(`/tasks/${id}`);
      return response.data;
    }
  });

  const { data: volunteers } = useQuery({
    queryKey: ['admin', 'volunteers'],
    queryFn: async () => {
      const response = await axiosClient.get('/users');
      return response.data.users.filter((u: { role: string; status: string }) => u.role === 'VOLUNTEER' && u.status === 'ACTIVE');
    }
  });

  const assignMutation = useMutation({
    mutationFn: async (volunteer_id: number) => {
      return axiosClient.post(`/tasks/${id}/assign`, { volunteer_id });
    },
    onSuccess: () => {
      notification.success({ message: 'Task assigned successfully' });
      setIsAssignModalVisible(false);
      queryClient.invalidateQueries({ queryKey: ['ngo', 'task', id] });
    }
  });

  if (isLoading) {
    return <div style={{ textAlign: 'center', padding: '80px' }}><Spin size="large" /></div>;
  }

  if (error || !task) {
    return (
      <Alert
        message="Error"
        description="Could not load task details. Please try again."
        type="error"
        showIcon
        style={{ margin: 24 }}
      />
    );
  }

  return (
    <div style={{ padding: '0 0 24px 0' }}>
      <Button icon={<ArrowLeftOutlined />} onClick={() => navigate(-1)} style={{ marginBottom: 16 }}>
        Back
      </Button>

      <Row gutter={24}>
        <Col xs={24} lg={16}>
          <Card
            title={
              <Space>
                <Title level={4} style={{ margin: 0 }}>{task.title}</Title>
                <Tag color={getStatusColor(task.status)}>{task.status}</Tag>
                {task.status === 'OPEN' && (
                  <Button type="primary" icon={<SendOutlined />} onClick={() => setIsAssignModalVisible(true)}>
                    Assign Task
                  </Button>
                )}
              </Space>
            }
          >
            <Paragraph>{task.description}</Paragraph>

            <Divider />

            <Descriptions column={2} size="small">
              <Descriptions.Item label={<span><EnvironmentOutlined /> Location</span>}>
                {task.location_name || 'N/A'}
              </Descriptions.Item>
              <Descriptions.Item label="Budget">
                {safeFormatCurrency(task.budget_pkr)}
              </Descriptions.Item>
              <Descriptions.Item label="Items Needed">
                {task.items_needed ?? '—'}
              </Descriptions.Item>
              <Descriptions.Item label="Created">
                {dayjs(task.created_at).format('DD MMM YYYY, HH:mm')}
              </Descriptions.Item>
              {task.claimed_at && (
                <Descriptions.Item label="Claimed">
                  {dayjs(task.claimed_at).format('DD MMM YYYY, HH:mm')}
                </Descriptions.Item>
              )}
            </Descriptions>
          </Card>
        </Col>

        <Col xs={24} lg={8}>
          <Card title={<span><UserOutlined /> Assignment</span>} style={{ marginBottom: 16 }}>
            {task.volunteer_name ? (
              <Space orientation="vertical" style={{ width: '100%' }}>
                <Text strong>{task.volunteer_name}</Text>
                <Text type="secondary">Assigned volunteer</Text>
              </Space>
            ) : (
              <Text type="secondary">No volunteer assigned yet.</Text>
            )}
          </Card>

          <Card title={<span><HistoryOutlined /> Timeline</span>}>
            {task.events && task.events.length > 0 ? (
              <Space orientation="vertical" style={{ width: '100%' }}>
                {task.events.map((ev: { id: number; event_type: string; user_name?: string; created_at: string }) => (
                  <div key={ev.id} style={{ borderBottom: '1px solid #f0f0f0', paddingBottom: 8 }}>
                    <Text strong>{ev.event_type}</Text>
                    {ev.user_name && <Text type="secondary"> by {ev.user_name}</Text>}
                    <br />
                    <Text type="secondary" style={{ fontSize: 12 }}>
                      {dayjs(ev.created_at).format('DD MMM YYYY, HH:mm')}
                    </Text>
                  </div>
                ))}
              </Space>
            ) : (
              <Text type="secondary">No events recorded.</Text>
            )}
          </Card>
        </Col>
      </Row>

      <Modal
        title="Assign Task to Volunteer"
        open={isAssignModalVisible}
        onOk={() => selectedVolunteer && assignMutation.mutate(selectedVolunteer)}
        onCancel={() => setIsAssignModalVisible(false)}
        confirmLoading={assignMutation.isPending}
      >
        <Select
          style={{ width: '100%' }}
          placeholder="Select a volunteer"
          onChange={(value: number) => setSelectedVolunteer(value)}
          options={volunteers?.map((v: { id: number; name: string }) => ({ label: v.name, value: v.id }))}
        />
      </Modal>
    </div>
  );
};

export default NgoTaskDetailPage;
