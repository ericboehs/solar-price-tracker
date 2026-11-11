import { Controller } from "@hotwired/stimulus"

// Chart.js comes from the vendored UMD build (vendor/javascript/chart.umd.min.js,
// v4.6.1), loaded by the product page; it defines window.Chart.

// Price history line chart. Data comes from data-price-chart-points-value:
// [{ label: "11/11", date: "11/11/2026", price: 1234.5 }, ...]
export default class extends Controller {
  static values = { points: Array }

  connect() {
    this.darkQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.onSchemeChange = () => this.render()
    this.darkQuery.addEventListener("change", this.onSchemeChange)
    this.render()
  }

  disconnect() {
    this.darkQuery.removeEventListener("change", this.onSchemeChange)
    this.chart?.destroy()
  }

  render() {
    this.chart?.destroy()
    const points = this.pointsValue
    const dark = this.darkQuery.matches
    const text = dark ? "#F3F4F6" : "#374151"
    const grid = dark ? "#374151" : "#E5E7EB"
    const pointBorder = dark ? "#1F2937" : "#FFFFFF"
    const money = (value) => "$" + Number(value).toFixed(2)

    this.chart = new window.Chart(this.element, {
      type: "line",
      data: {
        labels: points.map((p) => p.label),
        datasets: [{
          label: "Price ($)",
          data: points.map((p) => p.price),
          borderColor: "#EA580C",
          backgroundColor: "rgba(234, 88, 12, 0.1)",
          borderWidth: 2,
          fill: true,
          tension: 0.4,
          pointBackgroundColor: "#EA580C",
          pointBorderColor: pointBorder,
          pointBorderWidth: 2,
          pointRadius: 4,
          pointHoverRadius: 6
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        interaction: { intersect: false, mode: "index" },
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: dark ? "#1F2937" : "#FFFFFF",
            titleColor: text,
            bodyColor: text,
            borderColor: grid,
            borderWidth: 1,
            cornerRadius: 8,
            padding: 12,
            displayColors: false,
            callbacks: {
              title: (items) => points[items[0].dataIndex]?.date,
              label: (item) => money(item.parsed.y)
            }
          }
        },
        scales: {
          x: { grid: { color: grid }, ticks: { color: text, maxTicksLimit: 6 } },
          y: { beginAtZero: false, grid: { color: grid }, ticks: { color: text, callback: money } }
        }
      }
    })
  }
}
