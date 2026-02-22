import { api } from '../axios';
import { fixURI } from '../../utils';

const putData = (url: string, data: any): Promise<any> => {
  return api()
    .put(fixURI(url), data)
    .then((response) => {
      if (response?.status === 200) {
        return response?.data;
      }

      throw Error(response?.statusText);
    })
    .catch(({ response }) => {
      return response;
    });
};

export default putData;
