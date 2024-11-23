<template>
  <div class="afc-panel-wrapper">
    <panel
      :icon="mdiAdjust"
      :title="'AFC Spools'"
      card-class="afc-panel"
      :collapsible="true"
      :expanded="true"
    >
      <template #buttons>
        <v-btn icon tile :title="'Refresh AFC Spools'" @click="fetchSpoolData">
          <v-icon>{{ mdiRefresh }}</v-icon>
        </v-btn>
        <!--<v-menu :offset-y="true" :close-on-content-click="true" left>
          <template v-slot:activator="{ on, attrs }">
            <v-btn icon tile v-bind="attrs" v-on="on">
              <v-icon>{{ mdiDotsVertical }}</v-icon>
            </v-btn>
          </template>
          <v-list>
            <v-list-item>
              <v-list-item-title>Filament Icon Style</v-list-item-title>
            </v-list-item>
            <v-list-item>
              <v-checkbox
                v-model="mainsailIconSwitch"
                label="Mainsail Theme"
                @change="onIconStyleChange('mainsail')"
              ></v-checkbox>
            </v-list-item>-->
        <!--<v-list-item>
              <v-checkbox
                v-model="klipperScreenIconSwitch"
                label="KlipperScreen Theme"
                @change="onIconStyleChange('klipperscreen')"
              ></v-checkbox>
            </v-list-item>
            <v-list-item>
              <v-checkbox
                v-model="spoolManIconSwitch"
                label="Spoolman Theme"
                @change="onIconStyleChange('spoolman')"
              ></v-checkbox>
            </v-list-item>-->
        <!--<v-list-item>
              <v-checkbox
                v-model="noIconSwitch"
                label="No Icon"
                @change="onIconStyleChange('none')"
              ></v-checkbox>
            </v-list-item>
          </v-list>
        </v-menu>-->
      </template>

      <div
        v-for="(unit, unitName) in unitsData"
        :key="unitName"
        class="unit-section"
      >
        <h2 class="unit-title">{{ unitName.replace(/_/g, " ") }}</h2>
        <div class="hub-status">
          <span><strong>Hub Status:</strong></span>
          <span
            :class="{
              'status-light': true,
              'status-green': getHubStatus(unitName),
              'status-red': !getHubStatus(unitName),
            }"
          ></span>
          <span class="tool-status">
            <strong>Tool Status:</strong>
            <span
              :class="{
                'status-light': true,
                'status-green': toolStartSensorStatus,
                'status-red': !toolStartSensorStatus,
              }"
            ></span>
          </span>
        </div>
        <div class="spool-container" style="margin-top: 15px">
          <div
            v-for="(spool, index) in unit.spools"
            :key="index"
            class="spool-card"
            @click="openChangeSpoolDialog(spool, index)"
          >
            <div class="filament-reel" style="padding: 1rem">
              <spool-icon
                v-if="mainsailIconSwitch"
                :color="spool.color"
                style="width: 25%; float: right"
                class="mr-3"
              />
              <!-- 
                v-if="klipperScreenIconSwitch"
                populate using MG's CSS
              <div
              v-if="klipperScreenIconSwitch"
              :class="spool">
              </div>-->

              <!-- 
                v-if="spoolManIconSwitch"
                populate using Spoolmans
              -->
            </div>
            <h3>{{ spool.laneName }}</h3>
            <p v-if="spool.material">
              {{ spool.material }}
            </p>
            <p v-if="spoolWeight(spool)">
              {{ spoolWeight(spool) }}
            </p>
            <p>
              <!--{{ determineStatus(spool) }}-->
              <span
                :class="{
                  'status-light': true,
                  'status-not-ready': determineStatus(spool) === 'Not Ready',
                  'status-ready': determineStatus(spool) === 'Ready',
                  'status-in-tool': determineStatus(spool) === 'In Tool',
                }"
              >
              </span>
            </p>
          </div>
        </div>
      </div>
    </panel>
    <afc-change-spool-dialog
      :show-dialog="showChangeSpoolDialog"
      :index="index"
      :lane-data="selectedLane"
      @close="showChangeSpoolDialog = false"
      @fetch-spool="fetchSpoolData"
    />
  </div>
</template>

<script lang="ts">
import { Component, Mixins } from "vue-property-decorator";
import BaseMixin from "@/components/mixins/base";
import Panel from "@/components/ui/Panel.vue";
import { mdiAdjust, mdiRefresh, mdiDotsVertical } from "@mdi/js";
import AfcChangeSpoolDialog from "@/components/dialogs/AfcChangeSpoolDialog.vue";
import SpoolIcon from "@/components/ui/SpoolIcon.vue";

@Component({
  components: {
    Panel,
    AfcChangeSpoolDialog,
    SpoolIcon,
  },
})
export default class AfcPanel extends Mixins(BaseMixin) {
  mdiAdjust = mdiAdjust;
  mdiRefresh = mdiRefresh;
  mdiDotsVertical = mdiDotsVertical;
  mainsailIconSwitch: boolean = true;
  klipperScreenIconSwitch: boolean = false;
  spoolManIconSwitch: boolean = false;
  noIconSwitch: boolean = false;

  showChangeSpoolDialog = false;
  selectedLane: any = null; // This will hold data of the clicked lane

  spoolData: any[] = [];
  intervalId: number | null = null;
  systemData: any = null;
  isPanelOpen: number[] = [0];
  currentPage: number = 0;
  spoolsPerPage: number = 4;
  index: number = 0;
  unitsData: any = {};

  private lastValidData: any = null;

  async mounted() {
    await this.fetchSpoolData();
    this.intervalId = setInterval(this.fetchSpoolData, 5);
  }

  beforeDestroy() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
    }
  }

  fetchSpoolData() {
    const afcData = this.$store.state.printer.AFC
      ? JSON.parse(JSON.stringify(this.$store.state.printer.AFC))
      : null;

    if (afcData) {
      this.spoolData = this.extractLaneData(afcData);
      this.unitsData = this.groupByUnit(this.spoolData);
      this.systemData = afcData.system || {};
      for (const unitName in afcData) {
        if (afcData.hasOwnProperty(unitName) && unitName !== "system") {
          if (this.unitsData[unitName]) {
            this.unitsData[unitName].system = afcData[unitName].system || {};
          }
        }
      }
    } else {
      this.spoolData = [];
      this.unitsData = {};
      this.systemData = {};
    }
  }

  extractLaneData(spools: any) {
    const lanes = [];
    if (spools && typeof spools === "object") {
      for (const unitName in spools) {
        if (spools.hasOwnProperty(unitName) && unitName !== "system") {
          const unit = spools[unitName];
          for (const laneKey in unit) {
            if (
              unit.hasOwnProperty(laneKey) &&
              typeof unit[laneKey] === "object" &&
              laneKey !== "system"
            ) {
              const laneData = unit[laneKey];
              laneData.unitName = unitName;
              laneData.laneName = laneKey;
              lanes.push(laneData);
            }
          }
        }
      }
    }
    return lanes;
  }

  private groupByUnit(spoolData: any[]) {
    const units: any = {};
    spoolData.forEach((spool) => {
      const unitName = spool.unitName;
      if (!units[unitName]) {
        units[unitName] = { spools: [] };
      }
      units[unitName].spools.push(spool);
    });
    return units;
  }

  openChangeSpoolDialog(spool: any, index: number) {
    this.selectedLane = { spool, laneName: spool.laneName };
    this.showChangeSpoolDialog = true;
  }

  getHubStatus(unitName) {
    if (this.unitsData[unitName]?.system?.hub_loaded !== undefined) {
      return this.unitsData[unitName].system.hub_loaded;
    }
    return this.systemData?.hub_loaded || false;
  }

  get toolStartSensorStatus() {
    return this.systemData?.extruders?.extruder?.tool_start_sensor || false;
  }

  spoolWeight(spool: any) {
    const weight = parseInt(spool.weight, 10);
    return weight ? `${weight} g` : '';
  }

  private determineStatus(spool: any) {
    if (spool.load && spool.prep) {
      if (this.systemData && this.systemData.current_load === spool.laneName) {
        return "In Tool";
      }
      return "Ready";
    }
    return "Not Ready";
  }

  private onIconStyleChange(selectedStyle: string) {
    this.mainsailIconSwitch = false;
    this.klipperScreenIconSwitch = false;
    this.spoolManIconSwitch = false;
    this.noIconSwitch = false;

    // Set the selected one to true
    if (selectedStyle === "mainsail") {
      this.mainsailIconSwitch = true;
    } else if (selectedStyle === "klipperscreen") {
      this.klipperScreenIconSwitch = true;
    } else if (selectedStyle === "spoolman") {
      this.spoolManIconSwitch = true;
    } else if (selectedStyle === "none") {
      this.noIconSwitch = true;
    }
  }
}
</script>

<style scoped>
.afc-panel {
  background-color: #1e1e1e;
  color: #ffffff;
  margin-bottom: 16px;
}

.afc-panel-wrapper {
  margin-bottom: 24px;
}

.v-card-title {
  font-weight: bold;
  font-size: 1.5em;
  text-align: center;
  padding-bottom: 16px;
}

.unit-section {
  margin-bottom: 32px;
}

.unit-title {
  font-size: 1.5em;
  margin-bottom: 16px;
  text-align: center;
}

.spool-container {
  display: flex;
  flex-wrap: nowrap;
  justify-content: space-between;
  gap: 16px;
  padding: 8px;
}

.spool-card {
  background-color: #2e2e2e;
  border-radius: 8px;
  padding: 8px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  max-width: 180px;
  width: 100%;
  position: relative;
  cursor: hand;
  transition: box-shadow 0.3s;
  margin-bottom: 12px;
}

.spool-card:hover {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.filament-reel {
  position: absolute;
  top: -10px;
  right: -15px;
}

.spool-card p {
  margin: 8px 0;
}

.status-light {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  display: inline-block;
  margin-left: 5px;
}

.status-green {
  background-color: rgb(24, 177, 24);
}

.status-red {
  background-color: red;
}

.hub-status {
  text-align: center;
}

.tool-status {
  text-align: center;
  margin-left: 15px;
}

.status-not-ready {
  background-color: red;
}

.status-ready {
  background-color: rgb(26, 230, 26);
}

.status-in-tool {
  background-color: rgb(6, 197, 245);
}

.spool-ks {
  flex: 1;
  padding: 15px;
  background-color: #fff;
  border-radius: 5px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.spool-ks h4 {
  margin-bottom: 10px;
  color: #333;
}

.spool-ks p {
  margin: 5px 0;
  color: #666;
}
</style>
