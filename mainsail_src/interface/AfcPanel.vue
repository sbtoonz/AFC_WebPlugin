<template>
  <div class="afc-panel">
    <h1>AFC Spools</h1>
    <div id="spools-container">
      <div v-for="(lane, index) in spoolData" :key="index" :id="`spool${index + 1}`" class="spool">
        <h4>Spool {{ index + 1 }}</h4>
        <p><strong>Material:</strong> {{ lane.material || "N/A" }}</p>
        <p><strong>Color:</strong> {{ lane.color || "N/A" }}</p>
        <p><strong>Remaining Weight:</strong> {{ lane.remaining_weight || "N/A" }} g</p>
        <p><strong>Status:</strong> {{ lane.load ? "Loaded" : "Not Loaded" }}</p>
        <p><strong>Notes:</strong> {{ lane.notes || "N/A" }}</p>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'AfcPanel',
  data() {
    return {
      spoolData: [],
      intervalId: null,
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
  },
};
</script>

<style scoped>
.afc-panel {
  font-family: Arial, sans-serif;
  background-color: #f0f0f0;
  color: #333;
  line-height: 1.6;
  margin: 0;
  padding: 20px;
}

h1 {
  text-align: center;
  margin-bottom: 20px;
}

#spools-container {
  display: flex;
  gap: 10px;
}

.spool {
  flex: 1;
  padding: 15px;
  background-color: #fff;
  border-radius: 5px;
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.spool h4 {
  margin-bottom: 10px;
  color: #333;
}

.spool p {
  margin: 5px 0;
  color: #666;
}
</style>
