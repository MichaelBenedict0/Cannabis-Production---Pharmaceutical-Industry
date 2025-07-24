(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant ERR_ALREADY_EXISTS (err u409))
(define-constant ERR_INVALID_LICENSE (err u422))
(define-constant ERR_PRODUCT_RECALLED (err u423))
(define-constant ERR_PRESCRIPTION_INVALID (err u424))

(define-data-var next-plant-id uint u1)
(define-data-var next-prescription-id uint u1)
(define-data-var compliance-token-supply uint u1000000)

(define-map licenses 
  { entity: principal, license-type: (string-ascii 20) }
  { 
    is-valid: bool,
    expiry-block: uint,
    issued-by: principal
  }
)

(define-map plants
  { plant-id: uint }
  {
    grower: principal,
    strain: (string-ascii 50),
    planted-block: uint,
    current-stage: (string-ascii 20),
    lab-tested: bool,
    test-results: (optional (string-ascii 200)),
    is-recalled: bool,
    owner: principal
  }
)

(define-map lab-results
  { plant-id: uint, lab: principal }
  {
    thc-level: uint,
    cbd-level: uint,
    contaminants: (string-ascii 100),
    test-date: uint,
    approved: bool
  }
)

(define-map prescriptions
  { prescription-id: uint }
  {
    doctor: principal,
    patient: principal,
    plant-id: uint,
    quantity: uint,
    issued-block: uint,
    filled: bool,
    pharmacy: (optional principal)
  }
)

(define-map compliance-tokens
  { holder: principal }
  { balance: uint }
)

(define-map stakeholder-scores
  { entity: principal }
  { 
    compliance-score: uint,
    total-transactions: uint,
    violations: uint
  }
)

(define-read-only (get-license (entity principal) (license-type (string-ascii 20)))
  (map-get? licenses { entity: entity, license-type: license-type })
)

(define-read-only (get-plant (plant-id uint))
  (map-get? plants { plant-id: plant-id })
)

(define-read-only (get-lab-result (plant-id uint) (lab principal))
  (map-get? lab-results { plant-id: plant-id, lab: lab })
)

(define-read-only (get-prescription (prescription-id uint))
  (map-get? prescriptions { prescription-id: prescription-id })
)

(define-read-only (get-compliance-balance (holder principal))
  (default-to u0 (get balance (map-get? compliance-tokens { holder: holder })))
)

(define-read-only (get-stakeholder-score (entity principal))
  (map-get? stakeholder-scores { entity: entity })
)

(define-private (is-license-valid (entity principal) (license-type (string-ascii 20)))
  (match (map-get? licenses { entity: entity, license-type: license-type })
    license (and (get is-valid license) (> (get expiry-block license) stacks-block-height))
    false
  )
)

(define-private (award-compliance-tokens (recipient principal) (amount uint))
  (let 
    (
      (current-balance (get-compliance-balance recipient))
    )
    (map-set compliance-tokens 
      { holder: recipient }
      { balance: (+ current-balance amount) }
    )
  )
)

(define-private (update-compliance-score (entity principal) (points uint))
  (let
    (
      (current-score (default-to { compliance-score: u0, total-transactions: u0, violations: u0 }
                     (map-get? stakeholder-scores { entity: entity })))
    )
    (map-set stakeholder-scores
      { entity: entity }
      {
        compliance-score: (+ (get compliance-score current-score) points),
        total-transactions: (+ (get total-transactions current-score) u1),
        violations: (get violations current-score)
      }
    )
  )
)

(define-public (register-license (entity principal) (license-type (string-ascii 20)) (expiry-block uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-none (map-get? licenses { entity: entity, license-type: license-type })) ERR_ALREADY_EXISTS)
    (map-set licenses
      { entity: entity, license-type: license-type }
      {
        is-valid: true,
        expiry-block: expiry-block,
        issued-by: tx-sender
      }
    )
    (award-compliance-tokens entity u100)
    (ok true)
  )
)

(define-public (revoke-license (entity principal) (license-type (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? licenses { entity: entity, license-type: license-type })) ERR_NOT_FOUND)
    (map-set licenses
      { entity: entity, license-type: license-type }
      {
        is-valid: false,
        expiry-block: u0,
        issued-by: tx-sender
      }
    )
    (let
      (
        (current-score (default-to { compliance-score: u0, total-transactions: u0, violations: u0 }
                       (map-get? stakeholder-scores { entity: entity })))
      )
      (map-set stakeholder-scores
        { entity: entity }
        {
          compliance-score: (get compliance-score current-score),
          total-transactions: (get total-transactions current-score),
          violations: (+ (get violations current-score) u1)
        }
      )
    )
    (ok true)
  )
)

(define-public (plant-seed (strain (string-ascii 50)))
  (let
    (
      (plant-id (var-get next-plant-id))
    )
    (asserts! (is-license-valid tx-sender "grower") ERR_INVALID_LICENSE)
    (map-set plants
      { plant-id: plant-id }
      {
        grower: tx-sender,
        strain: strain,
        planted-block: stacks-block-height,
        current-stage: "seedling",
        lab-tested: false,
        test-results: none,
        is-recalled: false,
        owner: tx-sender
      }
    )
    (var-set next-plant-id (+ plant-id u1))
    (update-compliance-score tx-sender u10)
    (award-compliance-tokens tx-sender u50)
    (ok plant-id)
  )
)

(define-public (update-plant-stage (plant-id uint) (new-stage (string-ascii 20)))
  (let
    (
      (plant (unwrap! (map-get? plants { plant-id: plant-id }) ERR_NOT_FOUND))
    )
    (asserts! (is-eq tx-sender (get grower plant)) ERR_UNAUTHORIZED)
    (asserts! (not (get is-recalled plant)) ERR_PRODUCT_RECALLED)
    (map-set plants
      { plant-id: plant-id }
      (merge plant { current-stage: new-stage })
    )
    (update-compliance-score tx-sender u5)
    (ok true)
  )
)

(define-public (submit-lab-results (plant-id uint) (thc-level uint) (cbd-level uint) (contaminants (string-ascii 100)) (approved bool))
  (let
    (
      (plant (unwrap! (map-get? plants { plant-id: plant-id }) ERR_NOT_FOUND))
    )
    (asserts! (is-license-valid tx-sender "lab") ERR_INVALID_LICENSE)
    (asserts! (not (get is-recalled plant)) ERR_PRODUCT_RECALLED)
    (map-set lab-results
      { plant-id: plant-id, lab: tx-sender }
      {
        thc-level: thc-level,
        cbd-level: cbd-level,
        contaminants: contaminants,
        test-date: stacks-block-height,
        approved: approved
      }
    )
    (map-set plants
      { plant-id: plant-id }
      (merge plant { 
        lab-tested: true,
        test-results: (some contaminants)
      })
    )
    (update-compliance-score tx-sender u20)
    (award-compliance-tokens tx-sender u75)
    (ok true)
  )
)

(define-public (issue-prescription (patient principal) (plant-id uint) (quantity uint))
  (let
    (
      (prescription-id (var-get next-prescription-id))
      (plant (unwrap! (map-get? plants { plant-id: plant-id }) ERR_NOT_FOUND))
    )
    (asserts! (is-license-valid tx-sender "doctor") ERR_INVALID_LICENSE)
    (asserts! (get lab-tested plant) ERR_NOT_FOUND)
    (asserts! (not (get is-recalled plant)) ERR_PRODUCT_RECALLED)
    (map-set prescriptions
      { prescription-id: prescription-id }
      {
        doctor: tx-sender,
        patient: patient,
        plant-id: plant-id,
        quantity: quantity,
        issued-block: stacks-block-height,
        filled: false,
        pharmacy: none
      }
    )
    (var-set next-prescription-id (+ prescription-id u1))
    (update-compliance-score tx-sender u15)
    (award-compliance-tokens tx-sender u60)
    (ok prescription-id)
  )
)

(define-public (fill-prescription (prescription-id uint))
  (let
    (
      (prescription (unwrap! (map-get? prescriptions { prescription-id: prescription-id }) ERR_NOT_FOUND))
      (plant (unwrap! (map-get? plants { plant-id: (get plant-id prescription) }) ERR_NOT_FOUND))
    )
    (asserts! (is-license-valid tx-sender "pharmacy") ERR_INVALID_LICENSE)
    (asserts! (not (get filled prescription)) ERR_ALREADY_EXISTS)
    (asserts! (not (get is-recalled plant)) ERR_PRODUCT_RECALLED)
    (asserts! (< (- stacks-block-height (get issued-block prescription)) u1440) ERR_PRESCRIPTION_INVALID)
    (map-set prescriptions
      { prescription-id: prescription-id }
      (merge prescription { 
        filled: true,
        pharmacy: (some tx-sender)
      })
    )
    (update-compliance-score tx-sender u25)
    (award-compliance-tokens tx-sender u100)
    (ok true)
  )
)

(define-public (recall-product (plant-id uint))
  (let
    (
      (plant (unwrap! (map-get? plants { plant-id: plant-id }) ERR_NOT_FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set plants
      { plant-id: plant-id }
      (merge plant { is-recalled: true })
    )
    (ok true)
  )
)

(define-public (transfer-plant-ownership (plant-id uint) (new-owner principal))
  (let
    (
      (plant (unwrap! (map-get? plants { plant-id: plant-id }) ERR_NOT_FOUND))
    )
    (asserts! (is-eq tx-sender (get owner plant)) ERR_UNAUTHORIZED)
    (asserts! (not (get is-recalled plant)) ERR_PRODUCT_RECALLED)
    (map-set plants
      { plant-id: plant-id }
      (merge plant { owner: new-owner })
    )
    (update-compliance-score tx-sender u5)
    (update-compliance-score new-owner u5)
    (ok true)
  )
)
