import * as React from 'react';
import {Link, useHistory} from "react-router-dom";

import Box from '@mui/material/Box';
import Drawer from '@mui/material/Drawer';
import Button from '@mui/material/Button';
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import MenuIcon from '@mui/icons-material/Menu';

import {IoMdBusiness} from "react-icons/io";
import {CiDeliveryTruck} from "react-icons/ci";
import {TbSpeedboat} from 'react-icons/tb';
import {BsFillPersonVcardFill} from 'react-icons/bs';
import {MdOutlineCategory} from "react-icons/md";
import {RiRouteFill} from "react-icons/ri";
import {GiOrganigram} from 'react-icons/gi';
import {GrUserWorker} from 'react-icons/gr';
import {FaTasks} from 'react-icons/fa';
import {FiSettings, FiUserPlus} from "react-icons/fi";
import {AiOutlineHome} from "react-icons/ai";
import {BsQuestionDiamond} from "react-icons/bs";
import {HiLogin, HiLogout} from "react-icons/hi";
import {BiTask} from "react-icons/bi";

import {useAuth} from "../../state-management";


type Anchor = 'top' | 'left' | 'bottom' | 'right';

export interface MenuItemProps {
  id?: string;
  to?: string;
  display?: string;
  onClick?: () => void;
  icon?: any;
}

export interface MenuItemGroup {
  label?: string;
  icon?: any
  subItems?: MenuItemProps[]
}


export default function DrawerMenuButton() {
  
  const history = useHistory();
  
  const { state, logout } = useAuth();
  
  const initState = {
    top: false,
    left: false,
    bottom: false,
    right: false,
  }
  
  const [menuState, setMenuState] = React.useState(initState);
  
  const CustomMenuItem: React.FC<MenuItemProps> = ({
                                                     id,
                                                     to,
                                                     display,
                                                     onClick,
                                                     icon: Icon
                                                   }) => {
    const menuI = (
      <ListItemButton id={id} onClick={onClick}>
        <ListItemIcon className="ml-3">
          {Icon ? <Icon /> : null}
        </ListItemIcon>
  
        <ListItemText>
          {display}
        </ListItemText>
      </ListItemButton>
    );
    
    return to ? <Link key={to} style={{ textDecoration: "none", color: "black" }} to={to}>{menuI}</Link> : menuI;
  };
  
  const toggleDrawer =
    (anchor: Anchor, open: boolean) =>
      (event: React.KeyboardEvent | React.MouseEvent) => {
        if (event.type === 'keydown' &&
          ((event as React.KeyboardEvent).key === 'Tab' || (event as React.KeyboardEvent).key === 'Shift')) {
          return;
        }
        
        setMenuState({ ...menuState, [anchor]: open });
      };
  
  const handleLogout = async () => {
    await logout()
    history.push('/login')
  }
  
  const getMenuItems = () => {
    const authenticatedMenuItemGroups:MenuItemGroup[] = [
      {
        subItems: [
          {
            display: 'Home',
            icon: AiOutlineHome
          }
        ]
      },
      {
        label: 'Admin',
        subItems: [
          {
            display: 'Organizations',
            icon: GiOrganigram
          },
        ]
      },
      {
        label: 'Jobs Outline',
        subItems: [
          {
            display: 'Boat Types',
            icon: MdOutlineCategory
          },
          {
            display: 'Questions',
            icon: BsQuestionDiamond
          },
          {
            display: 'Master Tasks',
            icon: FaTasks
          },
          {
            display: 'Job Types',
            icon: RiRouteFill
          },
        ],
      },
      {
        label: 'Operations',
        subItems: [
          {
            display: 'Marinas',
            icon: IoMdBusiness
          },
          {
            display: 'Users',
            icon: GrUserWorker
          },
          {
            display: 'Trucks',
            icon: CiDeliveryTruck
          },
          {
            display: 'Customers',
            icon: BsFillPersonVcardFill
          },
          {
            display: 'Boats',
            icon: TbSpeedboat
          },
          {
            display: 'Jobs',
            icon: BiTask
          },
        ]
      },
      {
        label: 'Account',
        subItems: [
          {
            display: 'Settings',
            icon: FiSettings
          },
          {
            display: 'Logout',
            icon: HiLogout
          }
        ]
      }
    ]
    
    const unauthenticatedMenuItemGroups = [
      // {
      //   label: 'Signup',
      //   icon: FiUserPlus
      // },
      {
        label: 'Login',
        icon: HiLogin
      }
    ]
    
    return state.isAuthenticated ? authenticatedMenuItemGroups : unauthenticatedMenuItemGroups
  }
  
  const formatMenuItemId = (config: MenuItemProps) => {
    return config?.display?.toLowerCase().replace(' ', '-')
  }
  
  const renderMenuItemList = (items: MenuItemProps[]) => {
    return items?.map((item: MenuItemProps) => (
      <ListItem key={item?.id ?? item?.display} disablePadding>
        <CustomMenuItem
          id={`drawer-menu-btn-${formatMenuItemId(item)}`}
          onClick={item?.display === 'Logout' ? handleLogout : () => console.log(item)}
          icon={item?.icon}
          to={`/${formatMenuItemId(item)}`}
          display={item?.display}
        />
      </ListItem>
    ));
  }
  
  const renderList = (anchor: Anchor) => {
    return (
      <Box
        sx={{ width: 250 }}
        role="presentation"
        onClick={toggleDrawer(anchor, false)}
        onKeyDown={toggleDrawer(anchor, false)}
      >
        <List>
          {getMenuItems().map((config: MenuItemGroup) => (
            <ListItem key={config.label} disablePadding>
              {config.subItems ? (
                <List>
                  <ListItemText className="ml-3">{config.label}</ListItemText>
                  {renderMenuItemList(config.subItems)}
                </List>
              ): renderMenuItemList([{display: config.label, icon: config.icon}])}
            </ListItem>
          ))}
        </List>
      </Box>
    );
  }
  
  return (
    <div id='drawer-menu-btn'>
      {(['left'] as const).map((anchor) => (
        <React.Fragment key={anchor}>
          <Button onClick={toggleDrawer(anchor, true)}><MenuIcon/></Button>
          <Drawer
            anchor={anchor}
            open={menuState[anchor]}
            onClose={toggleDrawer(anchor, false)}
          >
            {renderList(anchor)}
          </Drawer>
        </React.Fragment>
      ))}
    </div>
  );
}