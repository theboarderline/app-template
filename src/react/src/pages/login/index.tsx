import * as React from 'react';
import { RouteComponentProps, withRouter } from 'react-router-dom';
import { AppBar, Toolbar } from '@material-ui/core';
import { InputForm } from '../../forms';
import './styles.scss';

const Login: React.FC<RouteComponentProps> = () => {

  return (
    <div className='lg-home'>
      <InputForm />
    </div>
  );
};

export default withRouter(Login);
