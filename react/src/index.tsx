import React from 'react';
import ReactDOM from 'react-dom';
import { BrowserRouter as Router } from 'react-router-dom';
import App from './App';
import reportWebVitals from './reportWebVitals';

const composeProviders = (...Providers: any[]) => (Child: any) => (
  props: any
): JSX.Element =>
  Providers.reduce(
    (acc, Provider) => <Provider>{acc}</Provider>,
    <Child {...props} />
  );

const WrappedApp = composeProviders(Router)(App);

ReactDOM.render(
  <React.StrictMode>
    <WrappedApp />
  </React.StrictMode>,
  document.getElementById('root')
);


// If you want to start measuring performance in your app, pass a function
// to log results (for example: reportWebVitals(console.log))
// or send to an analytics endpoint. Learn more: https://bit.ly/CRA-vitals
reportWebVitals();
