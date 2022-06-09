import * as React from 'react';
import { InputLabel, MenuItem, FormControl, Select } from '@material-ui/core';
import './styles.scss';

interface ChangeProps {
  value: unknown;
}

interface DropdownMenuProps {
  title: string;
  value: any;
  values: any[] | null;
  setValue: (value: any) => void;
}

const DropdownMenu: React.FC<DropdownMenuProps> = ({
  title,
  value,
  values,
  setValue,
}) => {
  const handleChange = (event: React.ChangeEvent<ChangeProps>) => {
    setValue(event.target.value);
  };

  return (
    <FormControl className='lg-dropdown' variant='outlined'>
      <InputLabel className='lg-dropdown--label' id='dropdown-label'>
        {title}
      </InputLabel>

      <Select
        labelId='dropdown-label'
        id='dropdown'
        value={value}
        onChange={handleChange}
        label={title}
        classes={{
          outlined: 'lg-dropdown--outlined',
        }}
        MenuProps={{
          className: 'lg-dropdown--menu',
          classes: {
            paper: 'lg-dropdown--paper',
            list: 'lg-dropdown--list',
          },
        }}
      >
        <MenuItem key={-1} value='' className='lg-dropdown--item'>
          All
        </MenuItem>
        {values?.map((val) => (
          <MenuItem key={val.id} value={val} className='lg-dropdown--item'>
            {val.name}
          </MenuItem>
        ))}
      </Select>
    </FormControl>
  );
};

export default DropdownMenu;
