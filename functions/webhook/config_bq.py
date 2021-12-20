BQ_PROJECT = "dev-data-project-yqo"

ZIP_BUFFER_QUERY_STRING = """
  -- With a given input zip code, return all zip codes within 1000 meters (1 KM)
WITH
  input_zip AS (
  SELECT
    zip_code_geom
  FROM
    `{bq_project}.remi.zip_codes` input_zip
  WHERE
    zip_code = '{source_zip}' )
SELECT
  p.provider_name
FROM
  `{bq_project}.remi.zip_codes` output_zips
JOIN
  input_zip
ON
  ST_DWithin(input_zip.zip_code_geom,
    output_zips.zip_code_geom,
    1000)
JOIN
  `{bq_project}.remi.providers` p
ON
  p.zip_code = output_zips.zip_code
LIMIT
  3;
"""

UC1_PT_QUERY_STRING = """
SELECT
  p.provider_name,
  p.address||', '||p.city||', '||p.state||', '||p.zip_code AS address
FROM
  `{bq_project}.remi.providers` p
JOIN
  `{bq_project}.remi.providers_services` ps
ON
  p.provider_id = ps.provider_id
WHERE
  ps.specialty_symptom = 'Vestibular'
  AND p.zip_code LIKE '{source_zip}%'
LIMIT
  3;
"""

# Fudging zip code here temporarily
UC3_MRI_QUERY_STRING = """
SELECT
  pic.interaction_charge,
  p.provider_name,
  p.address||', '||p.city||', '||p.state||', '||p.zip_code AS address
FROM
  `{bq_project}.remi.providers` p
JOIN
  `{bq_project}.remi.providers_interaction_charges` pic
ON
  pic.provider_id = p.provider_id
WHERE
  pic.interaction_service = "MRI" AND
  p.zip_code LIKE '{source_zip}%'
LIMIT
  3;
"""
