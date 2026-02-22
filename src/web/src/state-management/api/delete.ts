import { api } from '../axios';
import { fixURI } from '../../utils';

const deleteData = (url: string): Promise<void> => {
  return api()
    .delete(fixURI(url))
    .then((response) => {
      if (response?.status === 204) {
        return response;
      }

      throw Error(response?.statusText);
    })
    .catch(({ response }) => {
      return response;
    });
};

export default deleteData;
