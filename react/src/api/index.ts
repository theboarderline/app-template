import { api } from './axios';
import { fixURI } from '../utils';

const calculatePayout = (players: string): Promise<any> => {

  const lines = players.split(/\r?\n/).filter(Boolean);

  return api()
    .post(fixURI('payout'), {'input': lines.join(';')})
    .then((response) => {
      if (response?.status === 201 || response?.status === 200) {
        console.log('Success:', response)
        return response;
      }
      throw Error(response?.statusText);
    })
    .catch(({ response }) => {
      return response;
    });
};

export default calculatePayout;
