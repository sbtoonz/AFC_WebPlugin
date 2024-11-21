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
      </template>
      <div v-if="totalPages > 1" class="pagination-controls">
        <v-btn icon @click="prevPage" :disabled="currentPage === 0">
          <v-icon>mdi-chevron-left</v-icon>
        </v-btn>
        <span>Page {{ currentPage + 1 }} of {{ totalPages }}</span>
        <v-btn icon @click="nextPage" :disabled="currentPage >= totalPages - 1">
          <v-icon>mdi-chevron-right</v-icon>
        </v-btn>
      </div>
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
        </div>
        <div class="spool-container" style="margin-top: 24px">
          <div
            v-for="(spool, index) in unit.spools"
            :key="index"
            class="spool-card"
            @click="openChangeSpoolDialog(spool, index)"
          >
            <div class="filament-reel" style="padding: 1rem">
              <spool-icon :color="spool.color" style="width: 15%; float:left" class="mr-3" />
            </div>
            <h3>Spool {{ spool.LANE }}</h3>
            <p v-if="spool.material">
              <strong>Material:</strong> {{ spool.material }}
            </p>
            <p v-if="spool.remaining_weight">
              <strong>Remaining Weight:</strong>
              {{ spool.remaining_weight.toFixed(2) }} g
            </p>
            <p>
              <strong>Status:</strong>
              {{ determineStatus(spool) }}
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
import { mdiAdjust, mdiRefresh } from "@mdi/js";
import AfcChangeSpoolDialog from "@/components/dialogs/AfcChangeSpoolDialog.vue";
import SpoolIcon from "@/components/ui/SpoolIcon.vue";

@Component({
  components: {
    Panel,
    AfcChangeSpoolDialog,
    SpoolIcon
  },
})
export default class AfcPanel extends Mixins(BaseMixin) {
  mdiAdjust = mdiAdjust;
  mdiRefresh = mdiRefresh;

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
              typeof unit[laneKey] === "object"
              && unit[laneKey] !== "system"
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

  private get totalPages() {
    return Math.ceil(this.spoolData.length / this.spoolsPerPage);
  }

  private get unitNames() {
    return [...new Set(this.spoolData.map((spool) => spool.unitName))];
  }

  private get paginatedSpoolData() {
    const start = this.currentPage * this.spoolsPerPage;
    const end = start + this.spoolsPerPage;
    return this.spoolData.slice(start, end);
  }

  private prevPage() {
    if (this.currentPage > 0) {
      this.currentPage--;
    }
  }

  private nextPage() {
    if (this.currentPage < this.totalPages - 1) {
      this.currentPage++;
    }
  }

  private determineStatus(spool: any) {
    if (spool.load && spool.prep) {
      if (
        this.systemData &&
        this.systemData.current_load === `{leg${spool.LANE}}`
      ) {
        return "In Tool";
      }
      return "Ready";
    }
    return "Not Ready";
  }

  openChangeSpoolDialog(spool: any, index: number) {
    this.selectedLane = { spool, laneNumber: index + 1 };
    console.log(
      "this index and index",
      this.index,
      this.selectedLane.laneNumber
    );
    this.showChangeSpoolDialog = true;
  }

  getHubStatus(unitName) {
    if (this.unitsData[unitName]?.system?.hub_loaded !== undefined) {
      return this.unitsData[unitName].system.hub_loaded;
    }
    return this.systemData?.hub_loaded || false;
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
  top: -30px;
  right: -20px;
}

.spool-card p {
  margin: 8px 0;
}

.pagination-controls {
  display: flex;
  justify-content: center;
  align-items: center;
  margin: 16px 0;
}

.pagination-controls span {
  margin: 0 16px;
}

.status-light {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  display: inline-block;
  margin-left: 8px;
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
