import React from 'react'
import { Switch, Route, Redirect } from 'react-router-dom'
import { useAuth } from '../state-management'
import {
  Home,
  Users,
} from '../pages'

interface PrivateRouteProps {
  component: any
  path: string
}

interface RefreshableRouteProps {
  component: any
  path: string
  private?: boolean
}

const PrivateRoute: React.FC<PrivateRouteProps> = ({
     component: Component,
     path,
   }) => {
  const { state } = useAuth()
  
  const isAuth = state.isAuthenticated
  
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
  )
}

const RefreshableRoute: React.FC<RefreshableRouteProps> = ({
     private: isPrivate,
     component: Component,
     path,
   }) => {
  
  const [lastPath, setLastPath] = React.useState<string>('')
  
  const { state } = useAuth()

  const noRefreshPaths = ['/login', '/signup']
  
  React.useEffect(() => {
    const lastPath = localStorage.getItem('lastPath') || '/home'
    if (lastPath && !noRefreshPaths.find((path) => path === lastPath))
      setLastPath(lastPath)
  }, [])
  
  if (isPrivate)
    return (
      <PrivateRoute
        component={Component}
        path={path}
      />
    )
  
  return (
    <Route
      render={() => {
        return state.isAuthenticated ? <Redirect to={lastPath} /> : <Redirect to="/login" />;
      }}
    />
  )
    
    // return (
    //   <Route
    //     path="/"
    //     render={() => {
    //       const lastPath = localStorage.getItem('lastPath') || '/home';
    //       return state.isAuthenticated ? <Redirect to={lastPath} /> : <Redirect to="/login" />;
    //     }}
    //   />
    // )

}

const BaseRouter: React.FC = () => {
  return (
    <Switch>
      <Route path='/home' component={Home} />
      <PrivateRoute path='/users' component={Users} />
      
      <Route path='/' component={Home} />
      
    </Switch>
  )
}

export default BaseRouter
