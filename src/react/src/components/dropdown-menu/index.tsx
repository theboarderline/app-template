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
  setValue
}) => {
  const handleChange = (event: React.ChangeEvent<ChangeProps>) => {
    setValue(event.target.value);
  };
  
  const renderVal = (val: any) => {
    if (val?.name) return val.name
    if (val?.long_name) return val.long_name
    if (val?.locality) return `${val.locality}, ${val.state_data?.long_name || ''} : ${val.number}`
    return val
  }

  return (
    <FormControl className="cgs-dropdown" variant="outlined">
      <InputLabel className="cgs-dropdown--label" id="dropdown-label">
        {title}
      </InputLabel>

      <Select
        labelId="dropdown-label"
        id="dropdown"
        value={value}
        onChange={handleChange}
        label={title}
        classes={{
          outlined: 'cgs-dropdown--outlined'
        }}
        MenuProps={{
          className: 'cgs-dropdown--menu',
          classes: {
            paper: 'cgs-dropdown--paper',
            list: 'cgs-dropdown--list'
          }
        }}
      >
        {values?.map((val) => (
          <MenuItem key={val.id || val} value={val} className="cgs-dropdown--item">
            {renderVal(val)}
          </MenuItem>
        ))}
      </Select>
    </FormControl>
  );
};

export default DropdownMenu;
