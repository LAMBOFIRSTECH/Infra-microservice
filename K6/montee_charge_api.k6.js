// Not yet work
import http from 'k6/http';
import { sleep, check } from 'k6';

export let options = {
  vus: 100,            // 100 utilisateurs fictifs
  duration: '30s',     // pendant 30 secondes
};

export default function () {
  const res = http.get('https://localhost:8181/team-management/health');

  check(res, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });

  sleep(1);
}
