import React from 'react';
import { Row, Col, Card, Statistic, Typography, Alert, Spin } from 'antd';
import {
  DollarOutlined,
  SwapOutlined,
  ProjectOutlined,
  TeamOutlined,
  EnvironmentOutlined,
  ArrowUpOutlined,
} from '@ant-design/icons';
import { useQuery } from '@tanstack/react-query';
import axiosClient from '../../api/axiosClient';
import { API_ENDPOINTS } from '../../api/endpoints';
import { toNumber } from '../../utils/apiNormalizer';
import MapView from '../../components/map/MapView';

const { Title, Text } = Typography;

// ── Coloured icon badge ──────────────────────────────────────────────────────
const IconBadge: React.FC<{ icon: React.ReactNode; color: string; bg: string }> = ({
  icon,
  color,
  bg,
}) => (
  <div
    style={{
      width: 40,
      height: 40,
      borderRadius: 10,
      background: bg,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      fontSize: 18,
      color,
      flexShrink: 0,
    }}
  >
    {icon}
  </div>
);

// ── Small sub-stat ───────────────────────────────────────────────────────────
const SubStat: React.FC<{ label: string; value: number; color?: string }> = ({
  label,
  value,
  color,
}) => (
  <div style={{ textAlign: 'center' }}>
    <div
      style={{
        fontSize: 18,
        fontWeight: 700,
        color: color ?? '#1a202c',
        lineHeight: 1.2,
      }}
    >
      {value}
    </div>
    <div style={{ fontSize: 11, color: '#94a3b8', marginTop: 2 }}>{label}</div>
  </div>
);

// ── Main stat card ───────────────────────────────────────────────────────────
const StatCard: React.FC<{
  loading: boolean;
  icon: React.ReactNode;
  iconColor: string;
  iconBg: string;
  label: string;
  mainValue: string | number;
  mainPrefix?: string;
  subStats: Array<{ label: string; value: number; color?: string }>;
}> = ({ loading, icon, iconColor, iconBg, label, mainValue, mainPrefix, subStats }) => (
  <Card
    loading={loading}
    styles={{
      body: { padding: '20px 20px 16px' },
    }}
    style={{ borderRadius: 12 }}
  >
    <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12, marginBottom: 16 }}>
      <IconBadge icon={icon} color={iconColor} bg={iconBg} />
      <div style={{ flex: 1 }}>
        <div style={{ fontSize: 12, color: '#94a3b8', fontWeight: 500, marginBottom: 2 }}>
          {label}
        </div>
        <div style={{ display: 'flex', alignItems: 'baseline', gap: 4 }}>
          {mainPrefix && (
            <span style={{ fontSize: 12, color: '#64748b', fontWeight: 600 }}>
              {mainPrefix}
            </span>
          )}
          <span style={{ fontSize: 22, fontWeight: 800, color: '#0f172a', lineHeight: 1 }}>
            {typeof mainValue === 'number'
              ? mainValue.toLocaleString('en-PK')
              : mainValue}
          </span>
        </div>
      </div>
    </div>
    <div
      style={{
        display: 'flex',
        justifyContent: 'space-around',
        paddingTop: 12,
        borderTop: '1px solid #f1f5f9',
      }}
    >
      {subStats.map((s) => (
        <SubStat key={s.label} label={s.label} value={s.value} color={s.color} />
      ))}
    </div>
  </Card>
);

// ── Dashboard ────────────────────────────────────────────────────────────────

const DashboardPage: React.FC = () => {
  const { data: mapData, isLoading: loadingMap } = useQuery({
    queryKey: ['admin', 'map-data'],
    queryFn: async () => {
      const response = await axiosClient.get('/admin/map-data');
      return response.data.data;
    },
  });

  const { data: operationalData, isLoading: loadingOperational } = useQuery({
    queryKey: ['admin', 'operational'],
    queryFn: async () => {
      const response = await axiosClient.get(API_ENDPOINTS.ADMIN.OPERATIONAL);
      return response.data;
    },
  });

  const { data: donationStats, isLoading: loadingDonations, error: donationError } = useQuery({
    queryKey: ['admin', 'donations', 'stats'],
    queryFn: async () => {
      const response = await axiosClient.get(API_ENDPOINTS.ADMIN.DONATIONS_STATS);
      return response.data;
    },
  });

  const { data: withdrawalStats, isLoading: loadingWithdrawals, error: withdrawalError } = useQuery({
    queryKey: ['admin', 'withdrawals', 'stats'],
    queryFn: async () => {
      const response = await axiosClient.get(API_ENDPOINTS.ADMIN.WITHDRAWALS_STATS);
      return response.data;
    },
  });

  const { data: campaignStats, isLoading: loadingCampaigns, error: campaignError } = useQuery({
    queryKey: ['admin', 'campaigns', 'stats'],
    queryFn: async () => {
      const response = await axiosClient.get(API_ENDPOINTS.ADMIN.CAMPAIGNS_STATS);
      return response.data;
    },
  });

  const { data: userStats, isLoading: loadingUsers, error: userError } = useQuery({
    queryKey: ['admin', 'users', 'stats'],
    queryFn: async () => {
      const response = await axiosClient.get(API_ENDPOINTS.ADMIN.USERS_STATS);
      return response.data;
    },
  });

  const hasError = donationError || withdrawalError || campaignError || userError;

  return (
    <div style={{ paddingBottom: 32 }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 24 }}>
        <Title level={2} style={{ margin: 0 }}>
          System Overview
        </Title>
      </div>

      {hasError && (
        <Alert
          message="Some dashboard data could not be loaded"
          type="warning"
          showIcon
          style={{ marginBottom: 16 }}
        />
      )}

      {/* ── Stat cards ── */}
      <Row gutter={[16, 16]}>
        <Col xs={24} sm={12} lg={6}>
          <StatCard
            loading={loadingDonations}
            icon={<DollarOutlined />}
            iconColor="#1A56DB"
            iconBg="rgba(26,86,219,0.1)"
            label="Total Confirmed Donations"
            mainValue={toNumber(donationStats?.total_amount)}
            mainPrefix="PKR"
            subStats={[
              { label: 'Pending', value: toNumber(donationStats?.pending_count), color: '#F59E0B' },
              { label: 'Confirmed', value: toNumber(donationStats?.confirmed_count), color: '#10B981' },
            ]}
          />
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <StatCard
            loading={loadingWithdrawals}
            icon={<SwapOutlined />}
            iconColor="#7C3AED"
            iconBg="rgba(124,58,237,0.1)"
            label="Total Approved Withdrawals"
            mainValue={toNumber(withdrawalStats?.total_amount)}
            mainPrefix="PKR"
            subStats={[
              { label: 'Pending', value: toNumber(withdrawalStats?.pending_count), color: '#F59E0B' },
              { label: 'Approved', value: toNumber(withdrawalStats?.approved_count), color: '#10B981' },
            ]}
          />
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <StatCard
            loading={loadingCampaigns}
            icon={<ProjectOutlined />}
            iconColor="#0D9488"
            iconBg="rgba(13,148,136,0.1)"
            label="Total Raised (All Campaigns)"
            mainValue={toNumber(campaignStats?.total_raised)}
            mainPrefix="PKR"
            subStats={[
              { label: 'Total', value: toNumber(campaignStats?.total_count) },
              { label: 'Active', value: toNumber(campaignStats?.active_count), color: '#10B981' },
            ]}
          />
        </Col>
        <Col xs={24} sm={12} lg={6}>
          <StatCard
            loading={loadingUsers}
            icon={<TeamOutlined />}
            iconColor="#EA580C"
            iconBg="rgba(234,88,12,0.1)"
            label="Total Platform Users"
            mainValue={toNumber(userStats?.total_count)}
            subStats={[
              { label: 'NGOs', value: toNumber(userStats?.ngo_count), color: '#7C3AED' },
              { label: 'Volunteers', value: toNumber(userStats?.volunteer_count), color: '#1A56DB' },
              { label: 'Donors', value: toNumber(userStats?.donor_count), color: '#0D9488' },
              { label: 'Pending', value: toNumber(userStats?.pending_ngo_count), color: '#F59E0B' },
            ]}
          />
        </Col>
      </Row>

      {/* ── Map ── */}
      <Row gutter={[16, 16]} style={{ marginTop: 20 }}>
        <Col span={24}>
          <Card
            title={
              <span style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                <EnvironmentOutlined style={{ color: '#1A56DB' }} />
                Live Operational Map
              </span>
            }
            style={{ borderRadius: 12 }}
          >
            {loadingMap ? (
              <div style={{ textAlign: 'center', padding: '50px' }}>
                <Spin size="large" />
              </div>
            ) : mapData ? (
              <MapView tasks={mapData.tasks} volunteers={mapData.volunteers} />
            ) : null}
          </Card>
        </Col>
      </Row>

      {/* ── Operational bottlenecks ── */}
      <Row gutter={[16, 16]} style={{ marginTop: 20 }}>
        <Col span={24}>
          <Card
            title="Operational Bottlenecks (Forensic View)"
            loading={loadingOperational}
            style={{ borderRadius: 12 }}
          >
            <Row gutter={24}>
              <Col xs={24} sm={8}>
                <Statistic
                  title="Oldest Pending Donation"
                  value={operationalData?.oldest_pending_hours?.donation ?? 'None'}
                  suffix={operationalData?.oldest_pending_hours?.donation != null ? ' hours' : ''}
                  prefix={
                    (operationalData?.oldest_pending_hours?.donation || 0) > 24 ? (
                      <ArrowUpOutlined style={{ color: '#ef4444' }} />
                    ) : null
                  }
                  styles={{
                    content: {
                      color:
                        (operationalData?.oldest_pending_hours?.donation || 0) > 24
                          ? '#ef4444'
                          : 'inherit',
                    },
                  }}
                />
                <Text type="secondary">
                  {operationalData?.pending?.donations || 0} total pending
                </Text>
              </Col>
              <Col xs={24} sm={8}>
                <Statistic
                  title="Oldest Pending Withdrawal"
                  value={operationalData?.oldest_pending_hours?.withdrawal ?? 'None'}
                  suffix={operationalData?.oldest_pending_hours?.withdrawal != null ? ' hours' : ''}
                  styles={{
                    content: {
                      color:
                        (operationalData?.oldest_pending_hours?.withdrawal || 0) > 12
                          ? '#f59e0b'
                          : 'inherit',
                    },
                  }}
                />
                <Text type="secondary">
                  {operationalData?.pending?.withdrawals || 0} total pending
                </Text>
              </Col>
              <Col xs={24} sm={8}>
                <Statistic
                  title="Oldest Unverified Delivery"
                  value={operationalData?.oldest_pending_hours?.delivery ?? 'None'}
                  suffix={operationalData?.oldest_pending_hours?.delivery != null ? ' hours' : ''}
                />
                <Text type="secondary">
                  {operationalData?.pending?.deliveries || 0} awaiting coordinator
                </Text>
              </Col>
            </Row>
          </Card>
        </Col>
      </Row>

      {/* ── System status ── */}
      <Row gutter={[16, 16]} style={{ marginTop: 20 }}>
        <Col span={24}>
          <Card title="System Operational Status" style={{ borderRadius: 12 }}>
            <div style={{ display: 'flex', gap: 16, flexWrap: 'wrap' }}>
              <Alert
                title="Backend API: Online"
                type="success"
                showIcon
                style={{ flex: 1, minWidth: 200 }}
              />
              <Alert
                title="Database: Connected"
                type="success"
                showIcon
                style={{ flex: 1, minWidth: 200 }}
              />
              <Alert
                title="Payment Gateway: Sandbox"
                type="info"
                showIcon
                style={{ flex: 1, minWidth: 200 }}
              />
            </div>
          </Card>
        </Col>
      </Row>
    </div>
  );
};

export default DashboardPage;
