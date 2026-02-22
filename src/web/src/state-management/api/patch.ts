import { api } from '../axios';
import { fixURI } from '../../utils';

const patchData = (url: string, data: any): Promise<void> => {
  return api()
    .patch(fixURI(url), data)
    .then((response) => {
      if (response?.status === 200) {
        return response;
      }

      throw Error(response?.statusText);
    })
    .catch(({ response }) => {
      return response;
    });
};

export default patchData;
