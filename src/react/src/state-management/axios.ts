import axios from 'axios';
import { API_URL } from '../utils';

export const api = () => {
  // axios.defaults.withCredentials = true;
  // axios.defaults.xsrfHeaderName = 'X-CSRFTOKEN';
  // axios.defaults.xsrfCookieName = 'csrftoken';

  const token = localStorage.getItem('token');
  console.log('token', token)
  if (token) axios.defaults.headers.common.Authorization = `Bearer ${token}`;
  else (delete axios.defaults.headers.common.Authorization)

  return axios.create({ baseURL: API_URL, timeout: 60000 });
};

export default api();
