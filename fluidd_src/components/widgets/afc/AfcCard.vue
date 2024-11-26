<template>
  <div class="afc-panel-wrapper">
    <collapsable-card
      icon="$filament"
      :title="'AFC Spools'"
      draggable
      layout-path="dashboard.afc-card"
    >
      <template #buttons>
        <app-btn
          icon
          tile
          :title="'Refresh AFC Spools'"
          @click="fetchSpoolData"
        >
          <span class="icon-refresh"></span>
        </app-btn>
      </template>
      <div class="status-wrapper">
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
        <span class="buffer-status">
          <span v-if="systemData?.extruders?.extruder?.buffer_status">
            {{ bufferStatus() }}
          </span>
        </span>
      </div>
      <div
        v-for="(unit, unitName) in unitsData"
        :key="unitName"
        class="unit-section"
      >
        <div
          class="unit-header"
          style="display: flex; align-items: center; gap: 10px; border-bottom: 1px solid #ccc; padding-bottom: 10px; margin-bottom: 15px;"
        >
          <h2 class="unit-title" style="margin: 0">
            {{ String(unitName).replace(/_/g, " ") }}
          </h2>
          <span class="hub-status">
            <span><strong>Hub Status:</strong></span>
            <span
              :class="{
                'status-light': true,
                'status-green': getHubStatus(unitName),
                'status-red': !getHubStatus(unitName),
              }"
            ></span>
          </span>
        </div>
        <div class="spool-container" style="margin-top: 15px">
          <div
            v-for="(spool, index) in unit.spools"
            :key="index"
            class="spool-card"
          >
            <div class="filament-reel" style="padding: 1rem">
              <v-icon :color="spool.color" size="60px"> $filament </v-icon>
            </div>
            <div class="spool-header">
              <span
                :class="{
                  'status-light': true,
                  'status-not-ready': determineStatus(spool) === 'Not Ready',
                  'status-ready': determineStatus(spool) === 'Ready',
                  'status-in-tool': determineStatus(spool) === 'In Tool',
                }"
              >
              </span>
              <h3>{{ spool.laneName }}</h3>
            </div>
            <p v-if="spool.material">{{ spool.material }}</p>
            <p v-if="spool.weight">{{ spoolWeight(spool) }}</p>
          </div>
        </div>
      </div>
    </collapsable-card>
  </div>
</template>

<script lang="ts">
import { Component, Mixins } from "vue-property-decorator";
import StateMixin from "@/mixins/state";
import StatusLabel from "@/components/widgets/status/StatusLabel.vue";
import type { Macro } from "@/store/macros/types";
@Component({
  components: {
    StatusLabel,
  },
})
export default class AfcCard extends Mixins(StateMixin) {
  spoolData: any[] = [];
  private intervalId: ReturnType<typeof setInterval> | undefined;
  systemData: any = null;
  isPanelOpen: number[] = [0];
  currentPage: number = 0;
  spoolsPerPage: number = 4;
  unitsData: any = {};

  async mounted() {
    await this.fetchSpoolData();
    this.intervalId = setInterval(() => {
      this.fetchSpoolData();
    }, 50); // Refresh data every 10 seconds
  }

  beforeDestroy() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
    }
  }

  fetchSpoolData() {
    console.log("fetching spool data?");
    const afcData = this.$store.state.printer.printer.AFC
      ? JSON.parse(JSON.stringify(this.$store.state.printer.printer.AFC))
      : null;

    if (afcData) {
      console.log(afcData);
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

  getHubStatus(unitName: any) {
    if (this.unitsData[unitName]?.system?.hub_loaded !== undefined) {
      return this.unitsData[unitName].system.hub_loaded;
    }
    return this.systemData?.hub_loaded || false;
  }

  bufferStatus() {
    return this.systemData?.extruders?.extruder?.buffer_status || false;
  }

  get toolStartSensorStatus() {
    return this.systemData?.extruders?.extruder?.tool_start_sensor || false;
  }

  spoolWeight(spool: any) {
    const weight = parseInt(spool.weight, 10);
    return weight ? `${weight} g` : "";
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

.spool-container {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-evenly;
  gap: 8px;
  padding: 8px;
}

.unit-title {
  font-size: 1.5em;
  margin-bottom: 16px;
  text-align: left;
}

.spool-card {
  background-color: #2e2e2e;
  border-radius: 8px;
  padding: 8px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  flex: 1 1 calc(23% - 16px);
  max-width: 140px;
  min-width: 80px;
  position: relative;
  cursor: hand;
  transition: box-shadow 0.3s;
  margin-bottom: 8px;
  text-align: right;
}

.filament-reel {
  position: absolute;
  bottom: -10px;
  left: -10px;
}

.spool-card p {
  margin: 4px 0;
}

.spool-header {
  display: flex;
  align-items: center;
  gap: 5px;
}

.status-wrapper {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
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
  text-align: left;
  margin-left: 15px 0;
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
</style>
