import * as React from 'react';
import { Dropdown } from 'primereact/dropdown';
import {getPlaceholder} from "../../utils";

interface DropdownProps {
  label: string
  selected: any
  options: any[]
  setSelected: any
  filterBy?: string
  getName?: (option: any) => string
}

const DropdownComponent: React.FC<DropdownProps> = ({ label, selected, options, setSelected, filterBy, getName }) => {
  
  const getDisplayName = (option: any) => {
    if (getName)
      return getName(option);
    
    if (option?.name)
      return option?.name
    
    if (option?.title)
      return option?.title
    
    return option.full_name
  }
  
  const optionTemplate = (option: any) => {
    return (
      <div id={`${label}-item`} className={`${label}-item`}>
        <div>{getDisplayName(option)}</div>
      </div>
    );
  }
  
  
  const selectedTemplate = (option: any, props: any) => {
    if (option) {
      return (
        <div className={`selected-${label}-item selected-${label}-item-value`}>
          <div>{getDisplayName(option)}</div>
        </div>
      );
    }
    
    return (
      <span>
        {getPlaceholder(props?.placeholder)}
      </span>
    );
  }
  
  return (
    <Dropdown
      id={`${label}-form-dropdown`}
      filter={!!filterBy}
      filterBy={filterBy}
      value={selected}
      options={options}
      onChange={(e) => setSelected(e.value)}
      optionLabel={label}
      placeholder={`Select ${getPlaceholder(label)}`}
      valueTemplate={selectedTemplate}
      itemTemplate={optionTemplate}
    />
  );
};

export default DropdownComponent;
