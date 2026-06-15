import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { ConfigProvider, theme as antdTheme } from 'antd';
import AppRouter from './router/AppRouter';
import ErrorBoundary from './components/ErrorBoundary';
import './App.css';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      retry: 1,
      staleTime: 30_000,
    },
  },
});

function App() {
  return (
    <ErrorBoundary>
      <ConfigProvider
        theme={{
          token: {
            colorPrimary: '#1A56DB',
            colorSuccess: '#10B981',
            colorWarning: '#F59E0B',
            colorError: '#EF4444',
            colorInfo: '#3B82F6',
            borderRadius: 8,
            borderRadiusLG: 12,
            borderRadiusSM: 6,
            fontFamily:
              "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif",
            fontSize: 14,
            colorBgContainer: '#ffffff',
            colorBgLayout: '#f5f7fa',
          },
          components: {
            Layout: {
              siderBg: '#0f172a',
              triggerBg: '#1e293b',
            },
            Menu: {
              darkItemBg: '#0f172a',
              darkSubMenuItemBg: '#0f172a',
              darkItemSelectedBg: '#1A56DB',
              darkItemHoverBg: 'rgba(26,86,219,0.15)',
              darkGroupTitleColor: 'rgba(148,163,184,0.6)',
            },
            Button: {
              primaryShadow: '0 2px 8px rgba(26,86,219,0.25)',
            },
            Card: {
              boxShadow: '0 1px 4px rgba(0,0,0,0.06)',
            },
            Table: {
              headerBg: '#f8fafc',
              headerColor: '#475569',
              rowHoverBg: '#f0f7ff',
            },
          },
          algorithm: antdTheme.defaultAlgorithm,
        }}
      >
        <QueryClientProvider client={queryClient}>
          <AppRouter />
        </QueryClientProvider>
      </ConfigProvider>
    </ErrorBoundary>
  );
}

export default App;
