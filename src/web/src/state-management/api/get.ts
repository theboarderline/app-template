import { api } from '../axios';
import { fixURI, getError } from '../../utils';

const getData = (url: string): Promise<any> => {
  return api()
    .get(fixURI(url))
    .then((response) => {
      return response
    })
    .catch(({ response }) => {
      return response;
    });
};

export default getData;
