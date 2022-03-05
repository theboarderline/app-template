import { getData, postData } from './http';
import { Deal, DealType, House, Member, Question, State, Testimonial, User } from './types';


export const getCurrentUser = async (): Promise<User> => {
  return getData('check/')
    .then(({ results }) => {
      if (!results?.length) throw Error(results)
      return results[0];
    })
    .catch(({ response }) => {
      return response;
    });
}

export const getUser = async (username: string): Promise<User> => {
  return getData(`users/?username=${username}`)
    .then(({ results }) => {
      if (!results?.length) throw Error(results)
      return results[0];
    })
    .catch(({ response }) => {
      return response;
    });
}

export const getMembers = async (): Promise<Member[]> => {
  return getData('members/')
    .then(({ results }) => {
      if (!results?.length) throw Error(results)
      return results;
    })
    .catch(({ response }) => {
      return response;
    });
}


export const getQuestions = async (): Promise<Question[]> => {
  return getData('questions/')
    .then((data) => {
      return data;
    })
    .catch((error) => {
      console.log(error);
      return error;
    });
}