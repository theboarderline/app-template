import * as React from 'react';
import {useAuth} from "../../state-management";

const GoogleLogin: React.FC = () => {
  const { googleLogin } = useAuth();
  
  const className = 'google-login-button';
  
  React.useEffect(() => {
    if (window.google) {
      // @ts-ignore
      window.google?.accounts?.id?.initialize({
        client_id: '50336065372-urmm0ikcgqamger49gssluju3kfan309.apps.googleusercontent.com',
        callback: handleLogin
      })
      
      // @ts-ignore
      window.google?.accounts?.id?.renderButton(
        document.getElementById(className),
        { theme: 'outline', size: 'large', longtitle: true }
      )
    }
  }, [window.google])
  
  const handleLogin = async (response: any) => {
    if (!response || response?.error) {
      console.log('error', response.error)
      return
    }
    const res = await googleLogin(response.credential)
    console.log('SOCIAL LOGIN RES', res)
  }
  
  return (
    <div id={className}></div>
  )
};

export default GoogleLogin;
