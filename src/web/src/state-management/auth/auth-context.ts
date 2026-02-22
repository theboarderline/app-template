import { createContext } from 'react'
import { AuthDispatch } from './auth-reducer'
import {
  Org,
  User,
} from '../types'

export interface AuthState {
  logname: string | null
  user: User | undefined
  org: Org | undefined
  exp: string
  error: any
  loading: boolean
  isAuthenticated: boolean
}

export interface UserPayload {
  count: number
  next: null
  previous: null
  results: User[]
}

export interface AuthContextState {
  state: AuthState
  dispatch: AuthDispatch
}

export const defaultState = (): AuthState => ({
  logname: null,
  user: undefined,
  org: undefined,
  exp: '',
  error: '',
  loading: false,
  isAuthenticated: false,
})

export const AuthContext = createContext<AuthContextState>({
  state: defaultState(),
  dispatch: () => null,
})
