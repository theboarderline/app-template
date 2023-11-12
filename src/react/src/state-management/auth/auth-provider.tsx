import React, {
  useReducer,
  Reducer,
  useState,
  useEffect,
  ReactNode,
} from 'react';
import { authReducer, AuthAction } from './auth-reducer';
import {
  AuthContextState,
  defaultState,
  AuthContext,
  AuthState,
} from './auth-context';

export type AuthProviderI = (props: { children: ReactNode }) => JSX.Element;

export const AuthProvider: AuthProviderI = ({ children }) => {
  const [state, dispatch] = useReducer<Reducer<AuthState, AuthAction>>(
    authReducer,
    defaultState()
  );

  const [contextValue, setContextValue] = useState<AuthContextState>({
    state,
    dispatch,
  });

  useEffect(() => {
    setContextValue((newContextValue) => ({
      ...newContextValue,
      state,
    }));
  }, [state]);

  return (
    <AuthContext.Provider value={contextValue}>{children}</AuthContext.Provider>
  );
};
