import React from 'react';
import BaseRouter from './utils/router';
import { Layout } from './components';
import './style/main.scss';

declare global {
  interface Window {
    API_URL: string;
    STATIC_BUCKET: string;
  }
}

const App: React.FC = () => (
  <div className='lake-games'>
    <Layout>
      <BaseRouter />
    </Layout>
  </div>
);

export default App;
