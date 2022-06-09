import * as React from 'react';
import { Link } from 'react-router-dom';
import { AppBar, Toolbar, IconButton } from '@material-ui/core';
import { GiBigWave } from 'react-icons/gi';
import './styles.scss';
import { gcsBucket, STATIC_BUCKET } from '../../utils';

const Header: React.FC = () => {
  return (
    <>
      <AppBar
        position='fixed'
        className='lake-games--header'
        classes={{ colorPrimary: 'lake-games--header-primary' }}
      >
        <Toolbar/>
      </AppBar>
      <Toolbar />
    </>
  );
};

export default Header;
