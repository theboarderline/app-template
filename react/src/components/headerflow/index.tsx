import React from 'react';
import { NavLink } from 'react-router-dom';
import './style.scss';

interface HeaderflowProps {
  check: boolean
}

const Headerflow: React.FC<HeaderflowProps> = ({ check }) => {

  return (
    <div className='header-flow-item'>
      <NavLink activeClassName='link-focused' className={'header-flow-item-list'} to="/home">Home</NavLink>
      <NavLink activeClassName="link-focused" className={'header-flow-item-list'} to='/contact'>Contact Us</NavLink>
      <NavLink activeClassName='link-focused' className={'header-flow-item-list'} to='/faq'>FAQ</NavLink>
    </div >
  )
}

export default Headerflow