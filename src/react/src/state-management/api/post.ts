import { api } from '../axios';
import { fixURI } from '../../utils';

const postData = (url: string, data: any): Promise<any> => {

  return api()
    .post(fixURI(url), data)
    .then((response) => {
      return response
    })
    .catch(({ response }) => {
      return response;
    });
};

export default postData;
