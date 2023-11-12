import { useQuery, useMutation, gql } from '@apollo/client';

const GET_USERS = gql`
    query GetUsers {
        users {
            id
            full_name
            first_name
            last_name
            email
            phone
            marinas {
                id
                name
            }
            roles {
                id
                name
            }
            
            created_at
            updated_at
        }
    }
`;


const UPSERT_USER = gql`
    mutation UpsertUser($input: UserInput!) {
        upsertUser(input: $input) {
            id
            full_name
            first_name
            last_name
            email
            phone
            marinas {
                id
                name
            }
            roles {
                id
                name
            }
            created_at
        }
    }
`

const DELETE_USER = gql`
    mutation DeleteUser($id: ID!) {
        deleteUser(id: $id)
    }
`

const RESET_PASSWORD = gql`
    mutation ResetPassword($id: ID!) {
        resetPassword(id: $id) {
            password
        }
    }
`


export function useUsers() {
  const { data, error, loading } = useQuery(GET_USERS)
  
  const [upsertUserMutation] = useMutation(UPSERT_USER)
  const [deleteUserMutation] = useMutation(DELETE_USER)
  const [resetPasswordMutation] = useMutation(RESET_PASSWORD)
  
  const users = data?.users ?? []
  
  const upsertUser = async (input: any) => {
    const res = await upsertUserMutation({ variables: { input } })
    return res?.data?.upsertUser ?? {}
  }
  
  const deleteUser = async (id: number) => {
    const res = await deleteUserMutation({ variables: { id } })
    return res?.data?.deleteUser ?? res
  }
  
  const resetPassword = async (id?: number) => {
    const res = await resetPasswordMutation({ variables: { id } })
    return res?.data?.resetPassword
  }
  
  return {
    users,
    upsertUser,
    deleteUser,
    resetPassword,
    usersError: error,
    loadingUsers: loading
  }
}
