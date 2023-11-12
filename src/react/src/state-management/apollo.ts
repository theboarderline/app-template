import { ApolloClient, InMemoryCache, HttpLink } from '@apollo/client';
import { API_URL } from '../utils';
import {setContext} from "@apollo/client/link/context";

const httpLink = new HttpLink({
  uri: `${API_URL}/query`
});

const authLink = setContext((_, { headers }) => {
  // Get the JWT token from local storage.
  const token = localStorage.getItem('token');
  
  // Return the headers to the context so the http link can read them.
  return {
    headers: {
      ...headers,
      // Add the token to the Authorization header.
      authorization: token ? `Bearer ${token}` : '',
    },
  };
});

const client = new ApolloClient({
    link: authLink.concat(httpLink),
    cache: new InMemoryCache(),
});

export default client;