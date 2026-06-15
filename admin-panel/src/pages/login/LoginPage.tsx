import React, { useState } from 'react';
import { Form, Input, Button, Card, Typography, Layout, Alert } from 'antd';
import { UserOutlined, LockOutlined, HeartFilled } from '@ant-design/icons';
import { useAuthContext } from '../../auth/AuthContext.tsx';
import { useNavigate, Navigate } from 'react-router-dom';

const { Title, Text } = Typography;
const { Content } = Layout;

interface LoginFormValues {
  email?: string;
  password?: string;
}

const LoginPage: React.FC = () => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const { login, isAuthenticated } = useAuthContext();
  const navigate = useNavigate();

  if (isAuthenticated) {
    return <Navigate to="/dashboard" replace />;
  }

  const onFinish = async (values: LoginFormValues) => {
    if (!values.email || !values.password) return;
    setLoading(true);
    setError(null);
    try {
      await login(values.email, values.password);
      navigate('/dashboard');
    } catch {
      setError('Invalid email or password. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <Layout
      style={{
        minHeight: '100vh',
        background: 'linear-gradient(145deg, #0d1b2a 0%, #1a3a6b 55%, #0a2444 100%)',
      }}
    >
      <Content
        style={{
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: 'center',
          padding: '24px 16px',
        }}
      >
        {/* ── Brand header ── */}
        <div style={{ textAlign: 'center', marginBottom: 36 }}>
          <div
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: 14,
              marginBottom: 14,
            }}
          >
            <div
              style={{
                width: 52,
                height: 52,
                borderRadius: '50%',
                background: 'linear-gradient(135deg, #1A56DB, #1e40af)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                boxShadow: '0 6px 24px rgba(26,86,219,0.45)',
              }}
            >
              <HeartFilled style={{ color: 'white', fontSize: 24 }} />
            </div>
            <span
              style={{
                color: 'white',
                fontSize: 30,
                fontWeight: 800,
                letterSpacing: '-0.8px',
              }}
            >
              Relief<span style={{ color: '#60a5fa' }}>Net</span>
            </span>
          </div>
          <div
            style={{
              color: 'rgba(255,255,255,0.45)',
              fontSize: 11,
              letterSpacing: '2px',
              textTransform: 'uppercase',
              fontWeight: 500,
            }}
          >
            Humanitarian Relief Platform · Admin Console
          </div>
        </div>

        {/* ── Login card ── */}
        <Card
          style={{
            width: '100%',
            maxWidth: 420,
            boxShadow: '0 24px 64px rgba(0,0,0,0.45)',
            border: 'none',
            borderRadius: 16,
          }}
          styles={{ body: { padding: '36px 40px' } }}
        >
          <div style={{ textAlign: 'center', marginBottom: 28 }}>
            <Title level={3} style={{ margin: 0, color: '#0d1b2a', fontWeight: 700 }}>
              Sign in to continue
            </Title>
            <Text type="secondary" style={{ fontSize: 13 }}>
              Authorized personnel only
            </Text>
          </div>

          {error && (
            <Alert
              title={error}
              type="error"
              showIcon
              style={{ marginBottom: 20, borderRadius: 8 }}
              closable
              onClose={() => setError(null)}
            />
          )}

          <Form name="login" onFinish={onFinish} size="large" layout="vertical">
            <Form.Item
              name="email"
              label="Email address"
              rules={[
                { required: true, message: 'Please enter your email' },
                { type: 'email', message: 'Please enter a valid email' },
              ]}
            >
              <Input
                prefix={<UserOutlined style={{ color: '#9ca3af' }} />}
                placeholder="admin@example.com"
                style={{ borderRadius: 8 }}
              />
            </Form.Item>

            <Form.Item
              name="password"
              label="Password"
              rules={[{ required: true, message: 'Please enter your password' }]}
            >
              <Input.Password
                prefix={<LockOutlined style={{ color: '#9ca3af' }} />}
                placeholder="••••••••"
                style={{ borderRadius: 8 }}
              />
            </Form.Item>

            <Form.Item style={{ marginBottom: 0, marginTop: 8 }}>
              <Button
                type="primary"
                htmlType="submit"
                block
                loading={loading}
                style={{
                  height: 48,
                  fontSize: 15,
                  fontWeight: 600,
                  borderRadius: 10,
                  background: 'linear-gradient(135deg, #1A56DB, #1e40af)',
                  border: 'none',
                  boxShadow: '0 4px 12px rgba(26,86,219,0.3)',
                }}
              >
                Sign In
              </Button>
            </Form.Item>
          </Form>
        </Card>

        <div
          style={{
            marginTop: 28,
            color: 'rgba(255,255,255,0.2)',
            fontSize: 12,
            textAlign: 'center',
          }}
        >
          ReliefNet V2.1 · Secure Admin Console
        </div>
      </Content>
    </Layout>
  );
};

export default LoginPage;
