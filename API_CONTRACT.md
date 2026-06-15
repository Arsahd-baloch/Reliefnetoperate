# DisasterAid V2.1 API Contract

## Authentication
**Type:** JWT Bearer Token
**Header:** `Authorization: Bearer <token>`

### Auth Module (`/api/auth`)
*   **POST `/register`**
    *   **Auth Required:** No
    *   **Body:** `{ email?: string, phone?: string, password: string, name: string, role: string (DONOR|BENEFICIARY|VOLUNTEER|NGO|COORDINATOR), cnic?: string, locale?: string }`
    *   **Response:** `{ user: UserProfile, token: string }`
*   **POST `/login`**
    *   **Auth Required:** No
    *   **Body:** `{ email?: string, phone?: string, password: string }`
    *   **Response:** `{ user: UserProfile, token: string }`
*   **GET `/me`**
    *   **Auth Required:** Yes
    *   **Response:** `UserProfile`

### Tasks Module (`/api/tasks`)
*   **POST `/`**
    *   **Auth Required:** Yes (BENEFICIARY, NGO, ADMIN)
    *   **Body:** `{ title: string, source_type: string, latitude: number, longitude: number, items_needed: {item: string, quantity: number|string}[], budget_pkr?: number, ... }`
    *   **Response:** `Task`
*   **GET `/available`**
    *   **Auth Required:** Yes (VOLUNTEER)
    *   **Query:** `?lat=number&lng=number&radius=number`
    *   **Response:** `Task[]`
*   **POST `/:id/claim`**
    *   **Auth Required:** Yes (VOLUNTEER)
    *   **Response:** `{ message: string }`

### Deliveries Module (`/api/deliveries`)
*   **POST `/`**
    *   **Auth Required:** Yes (VOLUNTEER)
    *   **Body:** `{ task_id: number, photo_urls: string[], latitude: number, longitude: number, notes?: string }`
    *   **Response:** `Delivery`
*   **POST `/:id/verify`**
    *   **Auth Required:** Yes (COORDINATOR, ADMIN)
    *   **Body:** `{ verified: boolean, notes?: string }`
    *   **Response:** `{ verified: boolean, delivery_id: number }`

### Health Module (`/api/health`)
*   **GET `/`**
    *   **Auth Required:** No
    *   **Response:** `{ status: string, timestamp: string, version: string, database: string }`

### NGO Module (`/api/ngo`)
*   **GET `/profile`**
    *   **Auth Required:** Yes (NGO)
    *   **Response:** `NgoProfile`
*   **PATCH `/profile`**
    *   **Auth Required:** Yes (NGO)
    *   **Body:** `{ org_name?: string, description?: string, bank_name?: string, account_title?: string, account_number?: string }`
    *   **Response:** `NgoProfile`
*   **GET `/dashboard/stats`**
    *   **Auth Required:** Yes (NGO)
    *   **Response:** `{ data: { campaigns: {...}, donations: {...} } }`
*   **GET `/public/:id`**
    *   **Auth Required:** No
    *   **Response:** `{ data: { profile: NgoPublicProfile, campaigns: Campaign[] } }`
