import * as React from 'react';
import {MultiSelect} from "primereact/multiselect";
import {getPlaceholder, upperCaseFirst} from "../../utils";

interface MultiSelectProps {
  label: string
  filterBy: string
  selected: any[]
  options: any[]
  setSelected: any
  getName?: (option: any) => string
}

const MultiSelectComponent: React.FC<MultiSelectProps> = ({ label, filterBy, selected, options, setSelected, getName }) => {
  
  const getDisplayName = (option: any) => {
    if (getName)
      return getName(option);
    
    return option?.name ?? option?.title
  }
  
  const template = (option: any) => {
    return (
      <div id={`${label}-item-${option?.id}`} className={`${label}-item`}>
        <div>{getDisplayName(option)}</div>
      </div>
    );
  }
  
  const panelFooterTemplate = () => {
    const length = selected?.length ?? 0;
    
    return (
      <div id={`${label}s-panel-footer`} className="py-2 px-3">
        <b>{length}</b> item{length > 1 ? 's' : ''} selected.
      </div>
    );
  }
  
  const selectedTemplate = (option: any) => {
    if (option) {
      return (
        <div className={`selected-${label}-item selected-${label}-item-value`}>
          <div>{getDisplayName(option)}</div>
        </div>
      );
    }
    
    return `Select ${getPlaceholder(label)}s`
  }
  
  return (
    <MultiSelect
      id={`${label}s-form-dropdown`}
      value={selected}
      options={options}
      onChange={(e) => setSelected(e.value)}
      optionLabel={filterBy}
      placeholder={`Select ${upperCaseFirst(label)}s`}
      filter
      filterBy={filterBy}
      className={`${label}-multiselect-form-input`}
      itemTemplate={template}
      selectedItemTemplate={selectedTemplate}
      panelFooterTemplate={panelFooterTemplate}
    />
  );
};

export default MultiSelectComponent;
