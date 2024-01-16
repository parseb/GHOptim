
export function createDBsql() {
    return `CREATE TABLE
    public."Offer" (
      id serial NOT NULL,
      asset character varying(255) NULL,
      amount bigint NULL,
      "wantedPrice" bigint NULL,
      duration bigint NULL,
      taker character varying(255) NULL,
      lper character varying(255) NULL,
      "executionPrice" bigint NULL,
      modified_at timestamp(6) without time zone NULL DEFAULT now()
    );
  
  ALTER TABLE
    public."Offer"
  ADD
    CONSTRAINT "Offer_pkey" PRIMARY KEY (id)`;
}