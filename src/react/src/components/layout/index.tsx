import * as React from 'react'
import {useHistory} from "react-router-dom";
import {Header} from '..'
import {useAuth} from '../../state-management'
import './styles.scss'

const Layout: React.FC = ({ children }) => {
  const { state, getUser } = useAuth();
  const history = useHistory();
  
  
  React.useEffect(() => {
    console.log('GETTING USER')
    getUser().catch(({ error }) => {
      console.log('ERROR:', error)
    })
  }, [state.logname])
  
  React.useEffect(() => {
    const lastPath = localStorage.getItem('lastPath')
    const pathname = history.location.pathname
    console.log('LAST PATH:', lastPath)
    console.log('PATHNAME:', pathname)
    
    if (lastPath) {
      console.log('FOUND LAST PATH:', lastPath)
      history.push(lastPath);
    }
  }, [state.logname]);
  
  console.log('STATE:', state)

  return (
    <>
      <Header />
      {children}
    </>
  )
}

export default Layout
