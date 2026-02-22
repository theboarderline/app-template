import { Dispatch } from 'react'
import { AuthState, defaultState } from './auth-context'
import { getError } from '../../utils'
import {
  Org,
  User,
} from '../types'
import LogRocket from "logrocket"

export type AuthAction =
  | { type: 'SET_AUTHENTICATION'; token: string, logname: string; user: User | undefined; org: Org | undefined }
  | { type: 'START_AUTHENTICATION' }
  | { type: 'ERROR_AUTHENTICATION'; error: string }
  | { type: 'CLEAR_AUTHENTICATION' }
  | { type: 'RESET_AUTHENTICATION' }

export type AuthDispatch = Dispatch<AuthAction>

export const authReducer = (
  state: AuthState,
  action: AuthAction
): AuthState => {
  switch (action.type) {
    case 'START_AUTHENTICATION': {
      return { ...state, error: null, loading: true }
    }

    case 'ERROR_AUTHENTICATION': {
      const { error } = action
      console.log('ERROR:', error)
      const parsedError = getError(error)
      console.log('PARSED ERROR:', parsedError)
      return { ...state, error: parsedError, loading: false }
    }

    case 'SET_AUTHENTICATION': {
      const { token, logname, user, org } = action
      
      const exp = new Date(new Date().getTime() + 3600 * 1000).toString()
      if (exp) localStorage.setItem('exp', exp)
      
      if (logname) localStorage.setItem('logname', logname)
      
      if (org) localStorage.setItem('org', JSON.stringify(org))
      
      if (user) {
        localStorage.setItem('user', JSON.stringify(user))
        LogRocket.identify(String(user.id), {
          name: `${user.first_name} ${user.last_name}`,
          email: user.email || '',
        });
      }
      
      if (token !== '') localStorage.setItem('token', token)

      return {
        ...state,
        error: '',
        loading: false,
        isAuthenticated: true,
        logname,
        user,
        org,
        exp,
      }
    }

    case 'CLEAR_AUTHENTICATION': {
      localStorage.clear()
      return defaultState()
    }

    case 'RESET_AUTHENTICATION': {
      const logname = localStorage.getItem('logname')
      
      const token = localStorage.getItem('token')

      const user = JSON.parse(
        String(localStorage.getItem('user') || {})
      ) as User
      
      const org = JSON.parse(
        String(localStorage.getItem('org') || {})
      ) as Org
      
      const exp = localStorage.getItem('exp') || ''
      
      return {
        ...state,
        logname,
        user,
        org,
        exp,
        isAuthenticated:
          Boolean(token) || Boolean(logname) || Boolean(localStorage.getItem('logname')),
      }
    }

    default: {
      return {
        ...state,
      }
    }
  }
}
