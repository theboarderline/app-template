import React, { useState, useRef } from 'react'

import { DataTable } from 'primereact/datatable'
import { Column } from 'primereact/column'
import { Toast } from 'primereact/toast'
import { Button } from 'primereact/button'
import { Toolbar } from 'primereact/toolbar'
import { Dialog } from 'primereact/dialog'
import { InputText } from 'primereact/inputtext'

import {Loader, Message, MultiSelectComponent} from ".."
import {
  Marina,
  Role,
  User,
} from "../../state-management/types"
import './styles.scss'
import {useAuth} from "../../state-management";
import {BsFillPersonVcardFill, BsFillTelephoneInboundFill} from "react-icons/bs";
import {PatternFormat} from "react-number-format";
import {AiOutlineMail, AiOutlineUpload} from "react-icons/ai";
import {getTimeDiff, validateEmail, validatePhone} from "../../utils";
import {Badge, BadgeSeverityType} from "primereact/badge";
import {useUsers} from "../../hooks/useUsers";
import {Checkbox, CheckboxChangeParams} from "primereact/checkbox";


const UsersTable: React.FC = () => {
  
  const { state } = useAuth()
  const {
    users,
    resetPassword,
    upsertUser,
    deleteUser,
    loadingUsers,
    usersError
  } = useUsers()
  
  const [err, setErr] = useState<string>('')
  const [importLoading, setImportLoading] = useState<boolean>(false)
  
  const [items, setItems] = useState<User[]>([])
  const [item, setItem] = useState<User>()
  const [filteredItems, setFilteredItems] = useState<User[]>([])
  const [selectedItems, setSelectedItems] = useState([])
  
  const [firstName, setFirstName] = useState<string>('')
  const [lastName, setLastName] = useState<string>('')
  const [phone, setPhone] = useState<string>('')
  const [email, setEmail] = useState<string>('')
  const [selectedRoles, setSelectedRoles] = useState<Role[]>([])
  const [generatePassword, setGeneratePassword] = useState<boolean>(false)
  const [password, setPassword] = useState<string>('')
  const [selectedMarinas, setSelectedMarinas] = useState<Marina[]>([])
  
  const [resetPasswordDialog, setResetPasswordDialog] = useState<boolean>(false)
  const [itemDialog, setItemDialog] = useState<boolean>(false)
  const [importDialog, setImportDialog] = useState<boolean>(false)
  const [deleteItemDialog, setDeleteItemDialog] = useState<boolean>(false)
  const [deleteItemsDialog, setDeleteItemsDialog] = useState<boolean>(false)
  
  const [globalFilter, setGlobalFilter] = useState<string>('')
  
  const toast = useRef(null)
  const dt = useRef(null)
  
  const filterListHelper = (item: User, queryIn: string) => {
    if (!queryIn) return true
    
    const query = queryIn.toLowerCase()
    
    return item?.full_name?.toLowerCase()?.includes(query)
  }
  
  const initialLoad = async () => {
    setItems(await users?? [])
    setFilteredItems(await users?.filter((item: User) => item && filterListHelper(item, globalFilter)) ?? [])
  }
  
  React.useEffect(() => {
    initialLoad()
  }, [state.user?.id, loadingUsers])
  
  if (loadingUsers)
    return <Loader loading/>
  
  if (usersError)
    return <Message severity='error' message={usersError.message}/>
  
  const hideDialog = () => {
    setErr("")
    setSelectedMarinas([])
    setResetPasswordDialog(false)
    setPassword('')
    setItem(undefined)
    setFirstName("")
    setLastName("")
    setPhone("")
    setEmail("")
    setSelectedRoles([])
    setGeneratePassword(false)
    setItemDialog(false)
    setImportDialog(false)
    setErr('')
  }
  
  const hideDeleteItemDialog = () => {
    setDeleteItemDialog(false)
  }
  
  const hideDeleteItemsDialog = () => {
    setDeleteItemsDialog(false)
  }
  
  
  const saveItem = async () => {
    setErr('')
    
    if (!firstName || !lastName) {
      setErr('Please provide both first and last name')
      return
    }
    
    if (!phone && !email) {
      setErr('Please provide either phone or email')
      return
    } else if (email && !validateEmail(email)) {
      setErr('Invalid Email Address')
      return
    } else if (phone && !validatePhone(phone)) {
      setErr('Invalid Phone Number')
      return
    }
    
    let _items = [...filteredItems]
    
    const input = {
      id: item?.id,
      phone,
      email,
      first_name: firstName,
      last_name: lastName,
      generate_password: generatePassword,
      role_ids: selectedRoles?.map((role: Role) => role.id),
      marina_ids: selectedMarinas?.map((marina: Marina) => marina.id),
    }
    
    if (toast?.current) {
      const res = await upsertUser(input)
      if (res?.id) {
        hideDialog()
        
        if (item?.id) {
          const index = findIndexById(item?.id)
          _items[index] = res
        } else {
          _items.unshift(res)
        }
        
        setFilteredItems(_items)
        setItems(_items)
        // @ts-ignore
        toast.current.show({severity: 'success', summary: 'Successful', detail: `User ${item?.id ? 'Updated' : 'Added'}`, life: 3000})
      } else {
        // @ts-ignore
        toast.current.show({severity: 'error', summary: 'Error', detail: 'Updating User', life: 3000})
      }
    }
  }
  
  const editItem = (_item?: User) => {
    if (_item) {
      setItem({..._item})
      setSelectedMarinas(_item.marinas)
      setSelectedRoles(_item.roles)
      setFirstName(_item.first_name)
      setLastName(_item.last_name)
      setEmail(_item.email)
      setPhone(_item.phone)
    }
    setItemDialog(true)
  }
  
  const openResetPassword = (_item?: User) => {
    if (_item) {
      setItem({..._item})
    }
    setResetPasswordDialog(true)
  }
  
  const confirmDeleteItem = (item: User) => {
    setItem(item)
    setDeleteItemDialog(true)
  }
  
  const handleDeleteItem = async () => {
    if (toast?.current && item?.id) {
      const res = await deleteItem(item?.id).catch((e: any) => {
        setErr(e.message)
      })
      
      if (res && !res?.errors) {
        let _items = filteredItems.filter((i: User) => item.id !== i?.id)
        setItems(_items)
        setFilteredItems(_items)
        setItem(undefined)
        // @ts-ignore
        toast.current.show({ severity: 'success', summary: 'Successful', detail: 'User Deleted', life: 3000 })
      }
      else {
        // @ts-ignore
        toast.current.show({ severity: 'error', summary: 'Error', detail: 'Deleting User', life: 3000 })
      }
      
      setDeleteItemDialog(false)
    }
  }
  
  const handleGlobalFilterChange = (e: any) => {
    setGlobalFilter(e.target.value)
    setFilteredItems(items?.filter((item: User) => filterListHelper(item, e.target.value)))
  }
  
  const findIndexById = (id: number) => {
    let index = -1
    for (let i = 0; i < filteredItems?.length; i++) {
      if (filteredItems[i]?.id === id) {
        index = i
        break
      }
    }
    
    return index
  }
  
  const exportCSV = () => {
    // @ts-ignore
    dt?.current?.exportCSV()
  }
  
  const handleImportItems = async () => {
    setImportLoading(true)
    // const res = await importUser()
    // setImportLoading(false)
    
    // if (res?.status === 200) {
    //   if (toast?.current) {
    //     @ts-ignore
        // toast.current.show({severity: 'success', summary: 'Successful', detail: 'Items Imported', life: 3000})
      // }
    // } else {
    //   if (toast?.current) {
    //     @ts-ignore
        // toast.current.show({severity: 'error', summary: 'Error', detail: 'Importing Items', life: 3000})
      // }
    // }
    setImportDialog(false)
  }
  
  const confirmImport = () => {
    setImportDialog(true)
  }
  
  const confirmDeleteSelected = () => {
    setDeleteItemsDialog(true)
  }
  
  const deleteItem = async (id: number) => {
    return deleteUser(id)
  }
  
  const deleteSelectedItems = async () => {
    let _items = filteredItems.filter((val: User) => {
      // @ts-ignore
      return !selectedItems?.includes(val)
      
    })
    
    if (toast?.current) {
      await selectedItems.forEach(async (item: User) => {
        await deleteItem(item?.id)
      })
      setFilteredItems(_items)
      setDeleteItemsDialog(false)
      setSelectedItems([])
      // @ts-ignore
      toast.current.show({severity: 'success', summary: 'Success', detail: 'User Deleted', life: 3000})
    }
  }
  
  const resetUserPassword = async () => {
    setErr('')
    setPassword('')
    
    if (toast?.current && item) {
      let _item = item
      const res = await resetPassword(_item?.id).catch(e => {
        setErr(e.message)
      })
      
      if (res?.password) {
        setPassword(res.password)
        
        // @ts-ignore
        toast.current.show({severity: 'success', summary: 'Successful', detail: `Password reset for ${item?.full_name}`, life: 3000})
      } else {
        setErr("Error resetting password")
        // @ts-ignore
        toast.current.show({severity: 'error', summary: 'Error', detail: 'Resetting Password', life: 3000})
      }
    }
  }
  
  const leftToolbarTemplate = () => {
    return (
      <React.Fragment>
        <Button id="new-user-btn" label="New" icon="pi pi-plus" className="p-button-success mr-2" onClick={() => editItem(undefined)}/>
        <Button id="delete-user-btn" label="Delete" icon="pi pi-trash" className="p-button-danger" onClick={confirmDeleteSelected}
                disabled={!selectedItems || !selectedItems?.length}/>
      </React.Fragment>
    )
  }
  
  const rightToolbarTemplate = () => {
    return null
    // return (
    //   <React.Fragment>
    //     <Button label="Import" icon="pi pi-upload" className="p-button-primary mr-2" onClick={confirmImport}/>
    //     <Button label="Export" icon="pi pi-download" className="p-button-help" onClick={exportCSV}/>
    //   </React.Fragment>
    // )
  }
  
  const createdBodyTemplate = (rowData: User) => {
    return (
      <p>
        <AiOutlineUpload className="mr-3"/>
        <span className="text-s text-gray-500">
          Created {getTimeDiff(rowData?.created_at)}
        </span>
      </p>
    )
  }
  
  const nameBodyTemplate = (rowData: User) => {
    return (
      <p>
        <BsFillPersonVcardFill className='mr-3'/>
        {rowData?.full_name}
      </p>
    )
  }
  
  const marinaBodyTemplate = (rowData: User) => {
    return (
      <p>
        {rowData?.marinas?.length === 0 ? 'None' : null}
        <ol>
          {rowData?.marinas?.map((marina: Marina) => (
            <li>
              {marina?.name}
            </li>
          ))}
        </ol>
      </p>
    )
  }
  
  const phoneBodyTemplate = (rowData: User) => {
    return (
      <p>
        <BsFillTelephoneInboundFill className='mr-3'/>
        <PatternFormat value={rowData?.phone} displayType={'text'} format="(###) ###-####"/>
      </p>
    )
  }
  
  const emailBodyTemplate = (rowData: User) => {
    return (
      <p>
        <AiOutlineMail className='mr-3'/>
        {rowData?.email}
      </p>
    )
  }
  
  const renderRoleBadge = (role: Role) => {
    let severity: BadgeSeverityType = 'danger'
    
    if (role?.name === 'superadmin') severity = 'success'
    if (role?.name === 'admin') severity = 'info'
    if (role?.name === 'manager') severity = 'warning'
    
    return (
      <p>
        <Badge
          className='float-left mr-1'
          severity={severity}
          value={role?.name}
        />
      </p>
    )
  }
  
  const rolesBodyTemplate = (rowData: User) => {
    return rowData?.roles?.map((role: Role) => renderRoleBadge(role))
  }
  
  const actionBodyTemplate = (rowData: User) => {
    return (
      <React.Fragment>
        <Button
          id="edit-item-btn"
          icon="pi pi-pencil"
          className="p-button-rounded p-button-success mr-2"
          onClick={() => editItem(rowData)}
        />
        
        <Button
          id="reset-password-btn"
          icon="pi pi-key"
          className="p-button-rounded p-button-warning mr-2"
          onClick={() => openResetPassword(rowData)}
        />
        
        <Button
          id="delete-item-btn"
          icon="pi pi-trash"
          className="p-button-rounded p-button-danger"
          onClick={() => confirmDeleteItem(rowData)}
        />
      </React.Fragment>
    )
  }
  
  const header = (
    <div className="table-header">
      <h5 className="mx-0 my-1">Manage Users</h5>
      <span className="p-input-icon-left">
        <i className="pi pi-search"/>
        <InputText type="search" onInput={(e) => handleGlobalFilterChange(e)} placeholder="Search..."/>
      </span>
    </div>
  )
  
  const itemDialogFooter = (
    <React.Fragment>
      <Button id="cancel-item-btn" label="Cancel" icon="pi pi-times" className="p-button-text" onClick={hideDialog}/>
      <Button id="submit-item-btn" label="Submit" icon="pi pi-check" className="p-button-text" onClick={saveItem}/>
    </React.Fragment>
  )
  
  const importDialogFooter = (
    <>
      <Loader loading={importLoading}/>
      <React.Fragment>
        <Button label="Cancel" icon="pi pi-times" className="p-button-text" onClick={hideDialog}/>
        <Button label="Submit" icon="pi pi-check" className="p-button-text" onClick={handleImportItems}/>
      </React.Fragment>
    </>
  )
  
  const deleteItemDialogFooter = (
    <React.Fragment>
      <Button id="cancel-delete-item-btn" label="No" icon="pi pi-times" className="p-button-text" onClick={hideDeleteItemDialog}/>
      <Button id="submit-delete-item-btn" label="Yes" icon="pi pi-check" className="p-button-text" onClick={handleDeleteItem}/>
    </React.Fragment>
  )
  
  const deleteItemsDialogFooter = (
    <React.Fragment>
      <Button id="cancel-delete-items-btn" label="No" icon="pi pi-times" className="p-button-text" onClick={hideDeleteItemsDialog}/>
      <Button id="submit-delete-items-btn" label="Yes" icon="pi pi-check" className="p-button-text" onClick={deleteSelectedItems}/>
    </React.Fragment>
  )
  
  const resetPasswordDialogFooter = (
    <React.Fragment>
      <Button id="cancel-reset-password-btn" label="No" icon="pi pi-times" className="p-button-text" onClick={hideDialog}/>
      <Button id="submit-reset-password-btn" label="Yes" icon="pi pi-check" className="p-button-text" onClick={resetUserPassword}/>
    </React.Fragment>
  )
  
  return (
    <div className="datatable-crud-demo">
      <Toast ref={toast}/>
      <div className="card">
        <Toolbar className="mb-4" left={leftToolbarTemplate} right={rightToolbarTemplate}/>
        <Loader dialog loading={loadingUsers}/>
        
        <DataTable
          ref={dt}
          value={filteredItems}
          selection={selectedItems}
          onSelectionChange={(e) => {
            setSelectedItems(e.value)
          }}
          dataKey="id" paginator rows={10} rowsPerPageOptions={[5, 10, 25]}
          paginatorTemplate="FirstPageLink PrevPageLink PageLinks NextPageLink LastPageLink CurrentPageReport RowsPerPageDropdown"
          currentPageReportTemplate="Showing {first} to {last} of {totalRecords} Items"
          header={header} responsiveLayout="scroll">
          <Column selectionMode="multiple" headerStyle={{width: '3rem'}} exportable={false}/>
          <Column header="Name" body={nameBodyTemplate} sortable sortField="full_name" style={{minWidth: '4rem'}}/>
          <Column header="Marinas" body={marinaBodyTemplate} sortable sortField="marinas" style={{minWidth: '4rem'}}/>
          <Column header="Phone Number" body={phoneBodyTemplate} sortable sortField="phone" style={{minWidth: '4rem'}}/>
          <Column header="Email" body={emailBodyTemplate} sortable sortField="email" style={{minWidth: '4rem'}}/>
          <Column header="Roles" body={rolesBodyTemplate} sortable sortField="roles" style={{minWidth: '4rem'}}/>
          <Column header="Created" body={createdBodyTemplate} sortable sortField="created_at" style={{minWidth: '4rem'}}/>
          <Column body={actionBodyTemplate} exportable={false} style={{minWidth: '2rem'}}/>
        </DataTable>
      </div>
      
      <Dialog visible={importDialog} style={{width: '450px'}} header="Confirm" modal footer={importDialogFooter}
              onHide={hideDialog}>
        <div className="confirmation-content">
          <i className="pi pi-exclamation-triangle mr-3" style={{fontSize: '2rem'}}/>
          <span>Are you sure you want to import users from Google Sheets?</span>
        </div>
      </Dialog>
      
      <Dialog visible={deleteItemDialog} style={{width: '450px'}} header="Confirm" modal footer={deleteItemDialogFooter}
              onHide={hideDeleteItemDialog}>
        <div className="confirmation-content">
          <i className="pi pi-exclamation-triangle mr-3" style={{fontSize: '2rem'}}/>
          {item && <span>Are you sure you want to delete <b>{`${item?.full_name}`}</b>?</span>}
        </div>
      </Dialog>
      
      <Dialog visible={itemDialog} style={{width: '450px'}} header={item?.id ? 'Edit User' : 'New User'} modal className="p-fluid"
              footer={itemDialogFooter} onHide={hideDialog}>
        
        <div className="col-12">
          <InputText id="firstname-form-input" value={firstName} onChange={(e) => setFirstName(e.target.value)}
                     placeholder="First name"/>
        </div>
        
        <div className="col-12">
          <InputText id="lastname-form-input" value={lastName} onChange={(e) => setLastName(e.target.value)}
                     placeholder="Last name"/>
        </div>
        
        <div className="col-12">
          <InputText id="phone-form-input" value={phone} onChange={(e) => setPhone(e.target.value)}
                     placeholder="Phone Number"/>
        </div>
        
        <div className="col-12">
          <InputText id="email-form-input" value={email} onChange={(e) => setEmail(e.target.value)}
                     placeholder="Email"/>
        </div>
        
        <div className="col-12">
          <Checkbox id="generate-password-checkbox" checked={generatePassword} onChange={(e: CheckboxChangeParams) => setGeneratePassword(e.checked)} />
          <label htmlFor="generate-password-checkbox">Generate Password</label>
        </div>
        
        <Message message={err ? `Error: ${err}` : ''} severity={'error'}/>
      </Dialog>
      
      <Dialog visible={resetPasswordDialog} style={{width: '450px'}} header="Reset Password" modal
              footer={resetPasswordDialogFooter} onHide={hideDialog}>
        <div className="confirmation-content">
          <i className="pi pi-exclamation-triangle mr-3" style={{fontSize: '2rem'}}/>
          {item && <span>Are you sure you want to reset the password for <b>{`${item?.full_name}`}</b>?</span>}
          <br/>
          <br/>
          <Message message={err} severity={"error"}/>
          {password && <span>Generated Password: <b>{password}</b></span>}
        </div>
      </Dialog>
      
      <Dialog visible={deleteItemsDialog} style={{width: '450px'}} header="Confirm" modal
              footer={deleteItemsDialogFooter} onHide={hideDeleteItemsDialog}>
        <div className="confirmation-content">
          <i className="pi pi-exclamation-triangle mr-3" style={{fontSize: '2rem'}}/>
          {selectedItems?.length && <span>Are you sure you want to delete the selected list of users?</span>}
        </div>
      </Dialog>
    </div>
  )
}

export default UsersTable
