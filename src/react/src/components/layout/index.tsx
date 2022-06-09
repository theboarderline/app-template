import * as React from 'react';
import { Header } from '..';
import './styles.scss';

const Layout: React.FC = ({ children }) => {
  return (
    <>
      <Header />
      <div className='lake-games--layout'>{children}</div>
    </>
  );
};

export default Layout;
