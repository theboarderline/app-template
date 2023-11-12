import { useContext } from 'react';

import { AuthContext, AuthState, UserPayload } from './auth-context';
import {getData, postData, patchData} from '../api';
import jwt_decode from "jwt-decode";
import {User} from "../types";
import {AxiosResponse} from "axios";

export interface UseAuth {
  (): {
    googleLogin: (tokenString: string) => Promise<void>;
    
    emailLogin: (email: string, password: string) => Promise<AxiosResponse>;
    
    authCodeLogin: (phone: string, email: string) => Promise<AxiosResponse>;
    
    sendAuthCode: (code: number, phone?: string, email?: string) => Promise<AxiosResponse>;
    
    getUser: () => Promise<UserPayload>;
    
    refresh: () => Promise<void>;

    signup: (
        phone: string,
        email: string,
        firstName: string,
        lastName: string,
        password?: string,
        confirmPassword?: string,
        orgName?: string
    ) => Promise<AxiosResponse>;

    changePassword: (
      newPassword: string,
      confirmPassword: string
    ) => Promise<void>;

    forgotPassword: (email: string) => Promise<void>;

    supportEmail: (subject: string, body: string) => Promise<void>;

    uploadProfile: (file: File | undefined) => Promise<void>;
    
    changeUsername: (username: string) => Promise<void>;

    logout: () => Promise<void>;

    state: AuthState;
  };
}

export const useAuth: UseAuth = () => {
  const { state, dispatch } = useContext(AuthContext);

  const getUser = async (): Promise<any> => {
    dispatch({
      type: 'START_AUTHENTICATION',
    });
    return getData('auth/check')
      .then(({ data }) => {
        if (data?.user) {
          dispatch({
            type: 'SET_AUTHENTICATION',
            user: data?.user,
            org: data?.org,
            logname: data?.user?.email,
            token: ''
          });
        }
        
        return data
      })
      .catch(({ error }) => {
        dispatch({
          type: 'ERROR_AUTHENTICATION',
          error,
        });
        return error;
      });
  };
  
  const emailLogin = async (email: string, password: string): Promise<AxiosResponse> => {
    
    const formData = {
      email,
      password
    }
    
    dispatch({
      type: 'START_AUTHENTICATION',
    });
    
    return postData('auth/login', formData)
    .then((res) => {
      console.log('LOGIN RES:', res)
      const tokenString = res?.data?.token
      
      if (res?.status === 200) {
        dispatch({
          type: 'SET_AUTHENTICATION',
          logname: res.data.user?.email || '',
          token: tokenString,
          user: res.data.user,
          org: res.data.org
        });
      } else {
        dispatch({
          type: 'ERROR_AUTHENTICATION',
          error: res?.data,
        });
      }
      return res;
    })
    .catch((error) => {
      dispatch({
        type: 'ERROR_AUTHENTICATION',
        error,
      });
    });
  };
  
  const googleLogin = async (tokenString: string): Promise<void> => {
    
    const formData = {
      credential: tokenString
    }
    
    dispatch({
      type: 'START_AUTHENTICATION',
    });
    
    return postData('auth/google/callback', formData)
    .then((res) => {
      console.log('SOCIAL LOGIN RES:', res)
      if (res?.status === 200) {
        const user = jwt_decode(tokenString) as User
        console.log('USER:', user)
        
        dispatch({
          type: 'SET_AUTHENTICATION',
          logname: user.email || '',
          token: tokenString,
          user: user,
          org: undefined
        });
      } else {
        dispatch({
          type: 'ERROR_AUTHENTICATION',
          error: res?.data,
        });
      }
      return res;
    })
    .catch((error) => {
      dispatch({
        type: 'ERROR_AUTHENTICATION',
        error,
      });
    });
  };
  
  const sendAuthCode = async (code: number, phone?: string, email?: string): Promise<AxiosResponse> => {
    const formData = {
      code,
      phone,
      email
    }
    
    dispatch({
      type: 'START_AUTHENTICATION',
    });
    
    return postData('auth/login/phone/callback', formData)
    .then((res) => {
      console.log('LOGIN CODE RES:', res)
      if (res?.status === 200) {
        dispatch({
          type: 'SET_AUTHENTICATION',
          logname: res.data.user?.email,
          token: res.data.token,
          user: res.data.user,
          org: res.data.org,
        });
      } else {
        dispatch({
          type: 'ERROR_AUTHENTICATION',
          error: res?.data,
        });
      }
      return res;
    })
    .catch((error) => {
      dispatch({
        type: 'ERROR_AUTHENTICATION',
        error,
      });
    });
  };
  
  const authCodeLogin = async (phone: string, email: string): Promise<AxiosResponse> => {
    const formData = {
      phone,
      email
    }

    dispatch({
      type: 'START_AUTHENTICATION',
    });

    return postData('auth/login/phone', formData)
      .then((res) => {
        console.log('LOGIN RES:', res)
        return res;
      })
      .catch((error) => {
        dispatch({
          type: 'ERROR_AUTHENTICATION',
          error,
        });
      });
  };

  const refresh = async (): Promise<void> => {
    dispatch({
      type: 'RESET_AUTHENTICATION',
    });
  };

  const signup = async (
    phone: string,
    email: string,
    firstName: string,
    lastName: string,
    password?: string,
    confirmPassword?: string,
    orgName?: string
  ): Promise<AxiosResponse> => {
    
    const data = {
      org_name: orgName,
      first_name: firstName,
      last_name: lastName,
      email,
      phone,
      password,
      confirm_password: confirmPassword
    }
    
    console.log('REGISTER DATA:', data)

    dispatch({
      type: 'START_AUTHENTICATION',
    });

    return postData('auth/signup', data)
      .then((res) => {
        console.log('REGISTER RES:', res)
        if (res?.status === 201) {
          dispatch({
            type: 'SET_AUTHENTICATION',
            logname: email,
            token: res.data.token,
            user: res.data.user,
            org: res.data.org,
          });
          return res;
        }
        
        dispatch({
          type: 'ERROR_AUTHENTICATION',
          error: res?.data,
        });
        throw res;
        
      })
      .catch((error) =>
        dispatch({
          type: 'ERROR_AUTHENTICATION',
          error,
        })
      );
  };


  const changeUsername = async (username: string): Promise<void> => {
    const formData = {
      username: username.toLowerCase()
    }

    dispatch({
      type: 'START_AUTHENTICATION',
    });

    return patchData('auth/user/', formData)
      .then((res: any) => {
        if (res?.status !== 200) {
          dispatch({
            type: 'ERROR_AUTHENTICATION',
            error: res?.data,
          });
          return res
        }
        localStorage.setItem('logname', username.toLowerCase());
        dispatch({
          type: 'RESET_AUTHENTICATION',
        });
        return res;
      })
      .catch((error) => {
        console.log('CHANGE USERNAME ERROR:', error);
      });
  };

  const changePassword = async (
    newPassword: string,
    confirmPassword: string
  ): Promise<void> => {
    const formData = {
      new_password1: newPassword,
      new_password2: confirmPassword,
    }

    dispatch({
      type: 'START_AUTHENTICATION',
    });

    return postData('auth/password/change/', formData)
      .then((res) => {
        if (res?.status !== 200) {
          dispatch({
            type: 'ERROR_AUTHENTICATION',
            error: res?.data,
          });
        }
        return res;
      })
      .catch((error) => {
        console.log('CHANGE PASSWORD ERROR:', error);
      });
  };

  const forgotPassword = async (email: string): Promise<void> => {
    const formData = {
      email
    }
    

    dispatch({
      type: 'START_AUTHENTICATION',
    });

    return postData('auth/password/reset/', formData)
      .then((res) => {
        if (res?.status !== 201) {
          dispatch({
            type: 'ERROR_AUTHENTICATION',
            error: res?.data,
          });
        }
        return res;
      })
      .catch((error) => {
        console.log('FORGOT PASSWORD ERROR:', error);
      });
  };


  const uploadProfile = async (file: File | undefined): Promise<void> => {
    const formData = {
      filename: file || ''
    }

    dispatch({
      type: 'START_AUTHENTICATION',
    });

    return postData('profiles', formData)
      .then((res) => {
        if (res?.status !== 201) {
          dispatch({
            type: 'ERROR_AUTHENTICATION',
            error: res?.data,
          });
        }
        return res;
      })
      .catch((error) => {
        console.log('UPLOAD POST ERROR:', error);
      });
  };
  
  const supportEmail = async (subject: string, body: string): Promise<void> => {
    dispatch({
      type: 'START_AUTHENTICATION',
    });
    
    
    const formData = {
      subject: subject,
      message: body
    }

    return postData('support-email', formData)
      .then((res) => {
        if (res?.status !== 200)
          dispatch({
            type: 'ERROR_AUTHENTICATION',
            error: res?.data,
          });
        return res;
      })
      .catch((error) => {
        console.log('SUBMIT REPORT ERROR:', error);
      });
  };

  const logout = async (): Promise<void> => {

    dispatch({
      type: 'CLEAR_AUTHENTICATION',
    });
    
    // clear session entirely
    localStorage.clear();
    
    return Promise.resolve();
  };

  return {
    getUser,
    sendAuthCode,
    googleLogin,
    emailLogin,
    authCodeLogin,
    refresh,
    signup,
    changeUsername,
    supportEmail,
    uploadProfile,
    changePassword,
    forgotPassword,
    logout,
    state,
  };
};
