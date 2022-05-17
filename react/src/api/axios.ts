import axios from 'axios';
import { CURRENT_URL } from '../utils';

export const api = () => {
  // axios.defaults.withCredentials = true;
  // axios.defaults.xsrfHeaderName = 'X-CSRFTOKEN';
  // axios.defaults.xsrfCookieName = 'csrftoken';

  // const token = localStorage.getItem('token');
  // if (token) axios.defaults.headers.common.Authorization = `Token ${token}`;

  return axios.create({ baseURL: `${CURRENT_URL}api/`, timeout: 20000 });
};

export default api();
