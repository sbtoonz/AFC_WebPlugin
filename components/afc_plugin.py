import sys
import importlib.util
import os
import logging
import requests
from tornado.web import RequestHandler
import time

from .plugin import Plugin

logger = logging.getLogger(__name__)

class AFCPlugin(Plugin):
    def __init__(self, config):
        super().__init__(config)

        afc_directory = config.get('module_directory', '/home/pi/klipper/klippy/extras')
        afc_path = os.path.join(afc_directory, "AFC.py")
        spec = importlib.util.spec_from_file_location("afc", afc_path)
        afc_module = importlib.util.module_from_spec(spec)
        sys.modules["afc"] = afc_module
        spec.loader.exec_module(afc_module)

        self.afc_instance = afc_module.afc(config)
        self.server = config.get_server()
        self.spool_manager = self.server.lookup_component("spoolman")

        self.register_endpoint("/afc/spools", SpoolHandler, self.afc_instance, self.spool_manager)
        logger.info("AFC Plugin Initialized with Spool Endpoint")

class SpoolHandler(RequestHandler):
    def initialize(self, afc_instance, spool_manager_instance):
        self.afc = afc_instance
        self.spool_manager = spool_manager_instance

    def get(self):
        try:
            eventtime = time.time()
            afc_spools_data = self.afc.get_status(eventtime)  
            enriched_spools_data = {}

            for unit, lanes in afc_spools_data.items():
                if unit == "system":
                    continue

                enriched_spools_data[unit] = {}
                for lane, spool_info in lanes.items():
                    spool_id = spool_info.get('spool_id')
                    enriched_spool_info = spool_info.copy()

                    if spool_id:
                        self.spool_manager.set_active_spool(spool_id)
                        spoolman_response = requests.get(f"http://localhost:7125/server/spoolman/spool_id")
                        if spoolman_response.status_code == 200:
                            spoolman_data = spoolman_response.json()
                            enriched_spool_info.update({
                                "material": spoolman_data.get("material"),
                                "remaining_weight": spoolman_data.get("remaining_weight"),
                                "notes": spoolman_data.get("notes"),
                            })

                    enriched_spools_data[unit][lane] = enriched_spool_info

            enriched_spools_data["system"] = afc_spools_data["system"]
            self.write({"status": "success", "spools": enriched_spools_data})

        except Exception as e:
            logger.error(f"Failed to retrieve AFC spools data: {e}")
            self.write({"status": "error", "message": str(e)})
