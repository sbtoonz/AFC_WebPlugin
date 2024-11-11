<template>
  <v-expansion-panels>
    <v-expansion-panel class="afc-panel-wrapper">
      <v-expansion-panel-header>AFC Spools</v-expansion-panel-header>
      <v-expansion-panel-content>
        <v-card class="afc-panel">
          <v-card-text>
            <div class="spool-container">
              <div v-for="(spool, index) in spoolData" :key="index" class="spool-card">
                <h3>Spool {{ index + 1 }}</h3>
                <p><strong>Material:</strong> {{ spool.material }}</p>
                <p><strong>Color:</strong> {{ spool.color }}</p>
                <p><strong>Remaining Weight:</strong> {{ spool.remaining_weight ? spool.remaining_weight.toFixed(2) : 'N/A' }} g</p>
                <p><strong>Status:</strong> {{ determineStatus(spool, index) }}</p>
                <p><strong>Notes:</strong> {{ spool.notes }}</p>
              </div>
            </div>
          </v-card-text>
        </v-card>
      </v-expansion-panel-content>
    </v-expansion-panel>
  </v-expansion-panels>
</template>

<script>
export default {
  name: 'AfcPanel',
  data() {
    return {
      spoolData: [],
      intervalId: null,
      systemData: null,
    };
  },
  async mounted() {
    await this.fetchSpoolData();
    this.intervalId = setInterval(this.fetchSpoolData, 10000); // Refresh data every 10 seconds
  },
  beforeDestroy() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
    }
  },
  methods: {
    async fetchSpoolData() {
      try {
        const response = await fetch("/server/afc/spools");
        const data = await response.json();
        if (data.result && data.result.status === "success" && data.result.spools) {
          this.spoolData = this.extractLaneData(data.result.spools);
          this.systemData = data.result.spools.system;
        }
      } catch (error) {
        console.error("Error fetching AFC spool data:", error);
      }
    },
    extractLaneData(spools) {
      const lanes = [];
      for (let [unit, spool] of Object.entries(spools)) {
        if (unit !== "system") {
          for (let lane in spool) {
            lanes.push(spool[lane]);
          }
        }
      }
      return lanes;
    },
    determineStatus(spool) {
      if (spool.load && spool.prep && spool.loaded_to_hub) {
        if (this.systemData && this.systemData.current_load === `leg${spool.LANE}`) {
          return "Locked and loaded to tool";
        }
        return "Locked and Loaded";
      }
      return "Not Loaded";
    },
  },
};
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
  justify-content: space-around;
  gap: 16px;
  padding: 16px;
}

.spool-card {
  background-color: #2e2e2e;
  border-radius: 8px;
  padding: 16px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  max-width: 300px;
  width: 100%;
}

.spool-card p {
  margin: 8px 0;
}
</style>
