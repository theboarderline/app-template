import React from 'react';
import { Switch, Route, Redirect } from 'react-router-dom';
import {
  Login,
  Home,
} from '../pages';

interface PrivateRouteProps {
  component: any;
  path: string;
}

const PrivateRoute: React.FC<PrivateRouteProps> = ({
  component: Component,
  path,
}) => {

  const isAuth = false // state.isAuthenticated;

  return (
    <Route
      render={(props) =>
        isAuth ? (
          <Component path={path} {...props} />
        ) : (
          <Redirect
            to={{
              pathname: '/login',
              state: { previous: props.location },
            }}
          />
        )
      }
    />
  );
};

const BaseRouter = (): JSX.Element => (
  <Switch>
    <Route exact path='/' component={Home} />
    <Route path='/home' component={Home} />
    <Route path='/login' component={Login} />

    {/* <PrivateRoute path='/private' component={PrivateComponent} /> */}
  </Switch>
);

export default BaseRouter;
