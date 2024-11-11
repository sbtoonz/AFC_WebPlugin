<template>
  <v-expansion-panels expand>
    <v-expansion-panel class="afc-panel-wrapper">
      <v-expansion-panel-header>
        <div class="header-icon">
          <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="24" height="24" viewBox="0 0 128 128">
            <image x="6" width="116" height="128" xlink:href="data:img/png;base64,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"/>
          </svg>
        </div>
        AFC Spools
      </v-expansion-panel-header>
      <v-expansion-panel-content>
        <v-card class="afc-panel">
          <v-card-text>
            <div class="spool-container">
              <div v-for="(spool, index) in spoolData" :key="index" class="spool-card">
                <div class="filament-reel">
                  <svg width="50" height="50" viewBox="0 0 487.04 487.04">
                      <g>
                        <circle :style="{ fill: spool.color ? `#${spool.color}` : '#999' }" cx="243.52" cy="243.52" r="232.97" />
                        <circle :style="{ fill: '#e6e6e6' }" cx="243.52" cy="243.52" r="112.5" />
                        <path :style="{ fill: '#1e1e1e' }" d="M0,243.52c0,134.42,109.1,243.52,243.52,243.52,134.42,0,243.52-109.1,243.52-243.52S377.95,0,243.52,0C109.1,0,0,109.1,0,243.52Zm115.73,181.78c-52.4-39.5-86.52-98.59-94.52-163.72v-.09c-.68-5.43,1-10.89,4.6-15,3.6-4.12,8.79-6.51,14.26-6.57l118.36-1.33c18.99-.21,36.63,9.83,46.12,26.29,9.5,16.45,9.38,36.74-.3,53.09l-60.29,101.76c-2.8,4.73-7.48,8.03-12.87,9.1-5.39,1.06-10.98-.22-15.36-3.52ZM450.22,238.8c5.49,.06,10.7,2.46,14.31,6.59,3.62,4.13,5.3,9.61,4.63,15.06-8.01,65.13-42.12,124.22-94.52,163.72l-.07,.05c-4.37,3.29-9.93,4.57-15.3,3.51-5.37-1.06-10.03-4.36-12.82-9.06l-60.33-101.84c-9.68-16.34-9.8-36.64-.3-53.09,9.5-16.45,27.13-26.5,46.12-26.29l118.27,1.33ZM338.12,40.02c5.04,2.14,8.92,6.32,10.69,11.49,1.77,5.18,1.24,10.86-1.44,15.63l-58.03,103.17c-9.31,16.56-26.83,26.8-45.83,26.8-19,0-36.51-10.25-45.83-26.8l-57.99-103.09c-2.69-4.79-3.22-10.49-1.45-15.69,1.77-5.2,5.68-9.4,10.73-11.54,60.41-25.63,128.64-25.63,189.05,0l.08,.04Z" />
                      </g>
                    </svg>
                </div>
                <h3>Spool {{ index + 1 }}</h3>
                <p><strong>Material:</strong> {{ spool.material }}</p>
                <p><strong>Remaining Weight:</strong> {{ spool.remaining_weight ? spool.remaining_weight.toFixed(2) : 'N/A' }} g</p>
                <p><strong>Status:</strong> {{ determineStatus(spool, index) }}</p>
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
  position: relative;
}

.filament-reel {
  position: absolute;
  top: -20px;
  right: -20px;
}

.spool-card p {
  margin: 8px 0;
}
</style>
