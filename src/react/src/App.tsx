import React from 'react';
import epsagon from '@epsagon/web'
import { LIFECYCLE, APP_CODE, EPSAGON_TOKEN } from './utils/index.ts';
import BaseRouter from './utils/router';
import { Layout } from './components';
import './style/main.scss';


epsagon.init({
  token: EPSAGON_TOKEN,
  appName: `${LIFECYCLE}-${APP_CODE}`,
})

declare global {
  interface Window {
    LIFECYCLE: string,
    API_URL: string;
    AUTH_DOMAIN: string;
    FIREBASE_KEY: string;
    APP_CODE: string;
    EPSAGON_TOKEN: string;
    STATIC_BUCKET: string;
    GOOGLE_NUMBER?: string,
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
