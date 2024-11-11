import logging
import httpx  # Use httpx for asynchronous HTTP requests
from tornado.web import RequestHandler
from ..common import RequestType

logger = logging.getLogger(__name__)

class AFCPlugin:
    def __init__(self, config):
        self.server = config.get_server()
        self.spoolman_enabled = config.get('spoolman_enabled', True)
        self.spoolman_port = config.get('spoolman_port', 7912)
        self.spoolman_ip = config.get('spoolman_ip', 'localhost')  # Add the IP configuration

        self._register_endpoints()

        logger.info("AFC Plugin Initialized with Spool Endpoint")

    def _register_endpoints(self):
        self.server.register_endpoint(
            "/server/afc/spools",
            RequestType.GET,
            self._handle_spool_request,
        )

    async def _handle_spool_request(self, web_request):
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get("http://localhost/printer/objects/query?AFC")

            if response.status_code == 200:
                response_data = response.json()
                result = response_data.get("result", {})
                afc_status = result.get("status", {}).get("AFC", {})

                if isinstance(afc_status, dict):
                    if self.spoolman_enabled:
                        enriched_spools_data = await self._enrich_with_spoolman(afc_status)
                    else:
                        enriched_spools_data = afc_status
                    return {"status": "success", "spools": enriched_spools_data}
                else:
                    logger.error("Unexpected type for afc_status. Expected dict, got: "
                                 f"{type(afc_status).__name__}")
                    return {"status": "error", "message": "Unexpected response type from AFC endpoint."}
            else:
                logger.error(f"Failed to get AFC status, HTTP {response.status_code}")
                return {"status": "error", "message": "Failed to get AFC status"}

        except Exception as e:
            logger.error(f"Failed to retrieve AFC spools data: {e}")
            return {"status": "error", "message": str(e)}

    async def _enrich_with_spoolman(self, afc_status):
        enriched_data = {}

        async with httpx.AsyncClient() as client:
            try:
                spoolman_url = f"http://{self.spoolman_ip}:{self.spoolman_port}/api/v1/spool"
                spools_response = await client.get(spoolman_url)

                if spools_response.status_code == 200:
                    spools_data = spools_response.json()
                    logger.info(f"Successfully retrieved spools data from Spoolman: {spools_data}")

                    # Create a dictionary by ID for easier lookup
                    spools_by_id = {str(spool["id"]): spool for spool in spools_data}
                else:
                    logger.error(f"Failed to retrieve spools from Spoolman, HTTP {spools_response.status_code}")
                    spools_by_id = {}
                    logger.error("Spoolman response: " + spools_response.text)

            except Exception as e:
                logger.error(f"Failed to retrieve spools data from SpoolManager: {e}")
                spools_by_id = {}

            for unit, lanes in afc_status.items():
                if unit == "system":
                    enriched_data["system"] = afc_status["system"]
                    continue

                enriched_data[unit] = {}
                for lane, spool_info in lanes.items():
                    enriched_spool_info = spool_info.copy()
                    spool_id = str(spool_info.get("spool_id"))

                    if spool_id and spool_id in spools_by_id:
                        spoolman_data = spools_by_id[spool_id]
                        logger.info(f"Enriching spool {spool_id} with data: {spoolman_data}")

                        # Access the nested filament object
                        filament_data = spoolman_data.get("filament", {})
                        material = filament_data.get("material")
                        color = filament_data.get("color_hex")
                        remaining_weight = spoolman_data.get("remaining_weight")
                        notes = spoolman_data.get("notes")

                        logger.info(f"Material: {material}, Color: {color}, Remaining Weight: {remaining_weight}, Notes: {notes}")

                        enriched_spool_info.update({
                            "material": material,
                            "remaining_weight": remaining_weight,
                            "color": color,
                            "notes": notes,
                        })

                    else:
                        logger.warning(f"No matching spool found for spool_id: {spool_id}")

                    enriched_data[unit][lane] = enriched_spool_info

        return enriched_data

    async def component_init(self) -> None:
        logger.info("AFC Plugin Component Initialized")

    async def close(self):
        logger.info("AFC Plugin is shutting down")

def load_component(config) -> AFCPlugin:
    return AFCPlugin(config)
