import React from 'react';
import LogRocket from 'logrocket';

import 'primeicons/primeicons.css'
import 'primereact/resources/themes/lara-light-indigo/theme.css'
import 'primereact/resources/primereact.min.css'

import BaseRouter from './utils/router';
import { Layout } from './components';
import './style/main.scss';
import {LIFECYCLE} from "./utils";
import {useRouteChangeHandler} from "./hooks/history";


console.log('LIFECYCLE:', LIFECYCLE)
if (LIFECYCLE === 'prod')
  LogRocket.init('n0phks/prod-boatload')


declare global {
  interface Window {
    LIFECYCLE: string,
    API_URL: string;
    APP_CODE: string;
    PUBLIC_BUCKET: string;
    BACKEND_BUCKET: string;
    GOOGLE_MAPS_KEY: string;
  }
}

const App: React.FC = () => {
  useRouteChangeHandler()

return (
  <div className='lake-games'>
      <Layout>
        <BaseRouter />
      </Layout>
    </div>
  )
}

export default App;
