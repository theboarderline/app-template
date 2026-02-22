
export interface User {
  id: number
  org_id: number
  org: Org
  phone: string
  email: string
  password: string
  full_name: string
  first_name: string
  last_name: string
  marinas: Marina[]
  roles: Role[]
  created_at: string
  updated_at: string
}

export interface Role {
  id: number
  name: string
  created_at: string
  updated_at: string
}

export interface Org {
  id: number
  name: string
  num_marinas: number
  num_users: number
  num_customers: number
  num_jobs: number
  created_at: string
  updated_at: string
}

export interface Location {
  id: number
  name: string
  full_address: string
  address: string
  city: string
  state: string
  zipcode: string
  latitude: number
  longitude: number
  created_at: string
  updated_at: string
}

export interface Marina {
  id: number
  name: string
  website: string
  phone: string
  location: Location
  num_trucks: number
  num_boats: number
  num_customers: number
  num_jobs: number
  created_at: string
  updated_at: string
}


export interface Customer {
  id: number
  full_name: string
  first_name: string
  last_name: string
  primary_phone: string
  secondary_phone: string
  email: string
  full_address: string
  marina: Marina
  location: Location
  launch: Location
  created_at: string
  updated_at: string
}

export interface JobType {
  id: number
  name: string
  master_tasks: MasterTask[]
  questions: Question[]
  created_at: string
  updated_at: string
}

export interface BoatType {
  id: number
  name: string
  master_tasks: MasterTask[]
  questions: Question[]
  created_at: string
  updated_at: string
}

export interface QuestionType {
  id: number
  name: string
}

export interface Question {
  id: number
  title: string
  priority: number
  enabled: boolean
  possible_answers: string
  type: QuestionType
  master_tasks: MasterTask[]
  boat_types: BoatType[]
  job_types: JobType[]
  created_at: string
  updated_at: string
}

export interface MasterTask {
  id: number
  name: string
  description: string
  priority: number
  enabled: boolean
  boat_types: BoatType[]
  job_types: JobType[]
  is_predeparture: boolean
  is_postarrival: boolean
  questions: Question[]
  created_at: string
  updated_at: string
}

export interface Task {
  id: number
  job: Job
  master_task: MasterTask
  boat: Boat
  answers: Answer[]
  title: string
  description: string
  in_progress: boolean
  skipped: string
  skip_reason: string
  created_at: string
  updated_at: string
}

export interface Answer {
  id: number
  question: Question
  task: Task
  answer: string
  signed_url: string
  created_at: string
  updated_at: string
}

export interface Boat {
  id: number
  boat_type: BoatType
  customer: Customer
  marina: Marina
  color: string
  make: string
  model: string
  year: number
  short_description: string
  created_at: string
  updated_at: string
}

export interface Truck {
  id: number
  name: string
  license_plate: string
  marina: Marina
  created_at: string
  updated_at: string
}

export interface JobStats {
  num_total: number
  num_assigned: number
  num_unassigned: number
  num_in_progress: number
  num_completed: number
}

export interface Job {
  id: number
  name: string
  job_type: JobType
  pickup_location: Location
  launch_location: Location
  dropoff_location: Location
  customer: Customer
  boats: Boat[]
  filtered_boats: Boat[]
  tasks: Task[]
  marina: Marina
  driver: User
  passenger: User
  truck: Truck
  appointment: string
  appointment_date: string
  appointment_time: string
  status: string
  in_progress: boolean
  arrival_instructions: string
  arrived_at_pickup: boolean
  arrived_at_launch: boolean
  arrived_at_dropoff: boolean
  completed_at: string
  created_at: string
  updated_at: string
}

