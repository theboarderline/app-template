import * as React from 'react';
import {DrawerMenuButton} from '..';
import './styles.scss';

const Header: React.FC = () => {
  return (
    <>
      <header className="header">
        <div className="header__toolbar flex container">
          <DrawerMenuButton/>
        </div>
      </header>
    </>
  );
};

export default Header;
