# Day 14 — Exercises

## AI Evaluation & Benchmarking · Lab Worksheet

**Thời gian làm bài:** 9:15–12:00

**Domain:** OrbitTech Store Customer Support

Điền trực tiếp câu trả lời vào file này. Golden dataset 20 QA được viết một lần
duy nhất trong `golden_dataset.json`, không chép lại toàn bộ vào Markdown.

---

Từ 9:15–9:30, cài môi trường và chạy baseline tests theo `guide_lab.md`.

---

## Part 1 — Warm-up (9:30–9:45)

### Exercise 1.1 — RAGAS Metric Thresholds

Theo bài giảng:

- 0.8–1.0: Good — monitor, maintain.
- 0.6–0.8: Needs work — analyze failures, iterate.
- Dưới 0.6: Significant issues — investigate.

Với từng metric, xác định khi nào score thấp có thể chấp nhận và khi nào là
critical.

| Metric | Acceptable Low Score Scenario | Critical Low Score Scenario | Action Required |
|---|---|---|---|
| Faithfulness | Câu hỏi out-of-domain hoặc model từ chối trả lời ("Tôi không tìm thấy thông tin"), không bịa context. | Model hallucinate, bịa sai chính sách đổi trả hoặc thông số kỹ thuật sản phẩm gây thiệt hại. | Giảm temperature, bổ sung prompt constraint yêu cầu strictly grounded vào context. |
| Answer Relevance | Khi context thiếu thông tin, câu trả lời từ chối lịch sự và hỏi lại để làm rõ nhu cầu. | Trả lời lạc đề hoàn toàn, sao chép context không liên quan đến thắc mắc của user. | Cải thiện query parsing/expansion, bổ sung few-shot prompt hướng dẫn trả lời trọng tâm. |
| Context Recall | Câu hỏi mở/đơn giản chỉ cần một phần thông tin cốt lõi là đủ để trả lời đúng. | Bỏ sót hoàn toàn chunk chứa thông tin quyết định khiến answer sai hoặc thiếu nghiêm trọng. | Tăng top-k retrieval, tối ưu hóa chunk size và chiến lược chunking tài liệu. |
| Context Precision | Đang thiết lập top-k lớn (ví dụ k=10) phục vụ bước re-ranking tiếp theo. | Chunk liên quan bị đẩy xuống cuối hoặc đứng sau nhiều chunk gây nhiễu, làm giảm chất lượng sinh. | Thêm module Reranker (Cross-encoder), lọc similarity threshold, kết hợp Hybrid Search. |
| Completeness | Khách hàng chỉ yêu cầu xác nhận nhanh Yes/No hoặc thông tin ngắn gọn. | Bỏ sót các điều kiện ràng buộc quan trọng (hạn bảo hành, chi phí phát sinh, điều kiện áp dụng). | Bổ sung hướng dẫn tổng hợp đa khía cạnh (aspect-based) vào prompt sinh câu trả lời. |

### Exercise 1.2 — Bias trong LLM-as-a-Judge

Ba bias thường gặp:

- Position bias: judge ưu tiên answer xuất hiện trước.
- Verbosity bias: judge ưu tiên answer dài hơn.
- Self-preference: judge ưu tiên output giống chính model đó.

**Câu 1: Thiết kế experiment phát hiện position bias với ít nhất hai conditions.**


> Condition 1 (Forward order): Sinh ra 2 câu trả lời A và B, gửi kèm vào prompt, ghi nhận chuỗi quyết định của judge.
  Condition 2: Đổi ngược thứ tự thành B và A với cùng nội dung và prompt đánh giá.
 Nếu judge đổi phán quyết khi thay đổi vị trí các câu trả lời, position bias xuất hiện. Khắc phục bằng cách đánh giá cả 2 chiều và chỉ công nhận thắng khi nhất quán, hoặc tính trung bình điểm cả 2 lần.

**Câu 2: Làm thế nào giảm verbosity bias bằng rubric design?**

> Thiết kế rubric theo dạng atomic fact checklist: Chấm điểm dựa trên số lượng thông tin đúng và đầy đủ theo tiêu chuẩn thay vì cảm nhận độ trôi chảy. Thêm tiêu chí ngắn gọn và phạt trực tiếp các câu dài dòng mang tính lặp lại hoặc thêm thông tin không cần thiết. Định nghĩa rõ ràng thang điểm mẫu chỉ ra câu trả lời ngắn nhưng đủ ý vẫn đạt điểm tuyệt đối.

**Câu 3: Tại sao cần calibrate LLM judge với human labels?**

> LLM judge có thể mang bias cố hữu, lệch chuẩn định lượng làm chấm quá khắt khe hoặc quá dễ dãi hoặc không hiểu đúng ngữ cảnh nghiệp vụ. Cần đo độ tương quan giữa điểm của LLM judge với nhãn chuyên gia. Từ đó hiệu chỉnh rubric, few-shot examples và ngưỡng điểm để đảm bảo judge phản ánh đúng đánh giá của con người trước khi tự động hóa hoàn toàn.

### Exercise 1.3 — Evaluation trong CI/CD

**Câu 1: Chọn threshold để block deployment.**

| Metric | Threshold | Lý do |
|---|---:|---|
| Faithfulness | 0.85 | Ngăn ngừa tối đa hallucination; đảm bảo thông tin sản phẩm và chính sách chính xác, tránh rủi ro pháp lý/uy tín. |
| Answer Relevance | 0.80 | Đảm bảo câu trả lời trực diện, giải quyết đúng vấn đề của khách hàng, hạn chế dài dòng lạc đề. |
| Completeness | 0.75 | Đảm bảo bao quát đủ các thông tin cốt lõi, chấp nhận mức độ tóm tắt vừa phải để phản hồi nhanh. |

**Câu 2: Khi nào dùng offline evaluation, online evaluation và human review?**

> Offline evaluation: Chạy tự động trong CI/CD pipeline trên Golden Dataset trước khi deploy để phát hiện sớm regression nhanh và tiết kiệm chi phí.
Online evaluation: Chạy giám sát thời gian thực trên production traffic thông qua implicit feedback (thumbs up/down, CTR, tỷ lệ chuyển sang nhân viên) và sampling LLM-as-a-judge để phát hiện data drift hoặc lỗi phát sinh trong môi trường thực.
Human review: Tiến hành định kỳ hoặc trên các ca điểm thấp, ca tranh chấp, escalation phức tạp nhằm kiểm định lại LLM judge và liên tục cập nhật thêm test cases vào Golden Dataset.

---

## Part 2 — Core Coding (9:45–10:40)

Hoàn thiện các TODO bắt buộc trong `template.py`.

### Task 1 — Data Models

- `QAPair`: question, expected answer, gold context, metadata và retrieved contexts.
- `EvalResult`: answer-side scores, optional retrieval scores, pass/failure fields.
- `overall_score()`: trung bình Faithfulness, Relevance và Completeness.

### Task 2 — RAGASEvaluator

Answer-side:

- `evaluate_faithfulness(answer, context)`
- `evaluate_relevance(answer, question)`
- `evaluate_completeness(answer, expected)`

Retrieval-side:

- `evaluate_context_recall(contexts, expected)`
- `evaluate_context_precision(contexts, expected)`

Full pipeline:

- `run_full_eval(..., contexts=None)` luôn tính ba answer metrics.
- Nếu có `contexts`, tính và lưu thêm Context Recall và Context Precision.
- Retrieval scores không làm thay đổi `overall_score()` và pass rule gốc.

### Task 3 — LLMJudge

- `score_response(question, answer, rubric)`
- `detect_bias(scores_batch)`

### Task 4 — BenchmarkRunner

- `run(qa_pairs, agent_fn, evaluator)`
- `generate_report(results)`
- `run_regression(new_results, baseline_results)`
- `identify_failures(results, threshold)`

`BenchmarkRunner.run()` phải truyền `pair.retrieved_contexts` vào
`run_full_eval()`. Report phải có average của hai retrieval metrics.

### Task 5 — FailureAnalyzer

- `categorize_failures(failures)`
- `find_root_cause(failure)`
- `generate_improvement_suggestions(failures)`
- `generate_improvement_log(failures, suggestions)`

Kiểm tra:

```bash
pytest tests/ -v
```

`rerank_by_overlap()` là TODO bonus của Exercise 3.5. Test tương ứng được skip
nếu bạn chưa làm bonus.

---

## Part 3 — Golden Dataset & Real Benchmark (10:40–11:35)

### Exercise 3.1 — Build the Golden Dataset

Thiết kế và validate dataset theo Mục 5–6 trong `guide_lab.md`. Nội dung 20 QA
được điền trực tiếp trong `golden_dataset.json`; phần dưới chỉ ghi lại kết quả
và quyết định thiết kế, không chép lại toàn bộ QA.

**Kết quả dataset**

| Hạng mục | Kết quả |
|---|---|
| Tổng số records | ____ / 20 |
| Easy | ____ / 5 |
| Medium | ____ / 7 |
| Hard | ____ / 5 |
| Adversarial | ____ / 3 |
| Source documents được sử dụng | ____ / 10 |
| Validator status | PASS / FAIL |

**Ba case đại diện cho quyết định thiết kế**

| ID | Difficulty | Source document(s) | Vì sao case phù hợp với difficulty/attack type? |
|---|---|---|---|
| | | | |
| | | | |
| | | | |

**Điểm khó nhất khi xây dựng expected answer hoặc evidence là gì?**

> *Câu trả lời:*

**Xác nhận:**

- [ ] Mọi claim trong expected answer đều có evidence hỗ trợ.
- [ ] Không có questions trùng ý và không dùng kiến thức ngoài corpus.
- [ ] `python validate_golden_dataset.py` báo `PASS`.

### Exercise 3.2 — Benchmark Run

Chạy:

```bash
python domain_assistant.py
python evaluate_answers.py
```

Copy bảng terminal vào đây hoặc điền từ `artifacts/benchmark_results.json`.

| ID | Question (short) | Ctx Recall | Ctx Precision | Faithfulness | Relevance | Completeness | Overall | Passed? | Failure Type |
|---|---|---:|---:|---:|---:|---:|---:|---|---|
| E01 | | | | | | | | | |
| E02 | | | | | | | | | |
| E03 | | | | | | | | | |
| E04 | | | | | | | | | |
| E05 | | | | | | | | | |
| M01 | | | | | | | | | |
| M02 | | | | | | | | | |
| M03 | | | | | | | | | |
| M04 | | | | | | | | | |
| M05 | | | | | | | | | |
| M06 | | | | | | | | | |
| M07 | | | | | | | | | |
| H01 | | | | | | | | | |
| H02 | | | | | | | | | |
| H03 | | | | | | | | | |
| H04 | | | | | | | | | |
| H05 | | | | | | | | | |
| A01 | | | | | | | | | |
| A02 | | | | | | | | | |
| A03 | | | | | | | | | |

**Aggregate Report**

- Overall pass rate: ____%
- Avg Context Recall: ____
- Avg Context Precision: ____
- Avg Faithfulness: ____
- Avg Relevance: ____
- Avg Completeness: ____
- Failure type distribution: ____

**Ba cases có Overall Score thấp nhất**

1. ID: ____ | Score: ____ | Failure type: ____
2. ID: ____ | Score: ____ | Failure type: ____
3. ID: ____ | Score: ____ | Failure type: ____

**Nhận xét ngắn:** Metric nào yếu nhất? Kết quả gợi ý vấn đề nằm ở retrieval
hay generation?

> *Câu trả lời:*

### Exercise 3.3 — LLM-as-a-Judge Rubric Design

Thiết kế rubric domain-specific cho OrbitTech Customer Support. Mỗi mức phải
đủ cụ thể để hai người chấm độc lập có thể hiểu giống nhau.

Chọn 3–5 dimensions:

- [ ] Correctness
- [ ] Completeness
- [ ] Relevance
- [ ] Evidence/citation
- [ ] Actionability
- [ ] Safety/privacy
- [ ] Tone/clarity
- [ ] Dimension khác: __________

| Score | Tiêu chí domain-specific | Ví dụ response |
|---:|---|---|
| 5 | | |
| 4 | | |
| 3 | | |
| 2 | | |
| 1 | | |

**Ba edge cases khó chấm**

| Edge Case | Tại sao khó chấm? | Rubric xử lý thế nào? |
|---|---|---|
| | | |
| | | |
| | | |

**Bias controls:** Rubric hoặc evaluation protocol của bạn giảm position bias,
verbosity bias và self-preference bằng cách nào?

> *Câu trả lời:*

### Exercise 3.4 — Framework Comparison (Bonus +5)

Chỉ làm sau khi hoàn thành 3.1–3.3. Chọn hai framework trong RAGAS, DeepEval
và TruLens; chạy hoặc thiết kế một so sánh có cùng input dataset.

| Tiêu chí | Framework 1: ____ | Framework 2: ____ |
|---|---|---|
| Setup complexity | | |
| Metrics available | | |
| CI/CD integration | | |
| Kết quả trên cùng dataset | | |
| Insight rút ra | | |

- Scores có nhất quán không?
- Framework nào strict hơn và vì sao?
- Hai framework có tìm ra cùng failure cases không?

> *Phân tích:*

### Exercise 3.5 — Retrieval Reranking (Bonus +5)

Mục tiêu: kiểm tra việc đổi thứ tự chunks có tăng Context Precision mà không
thay đổi Context Recall hay không.

1. Chọn ít nhất 5 cases từ `artifacts/actual_answers.json`.
2. Tính Context Recall và Context Precision trước rerank.
3. Implement `rerank_by_overlap()` hoặc một reranker khác.
4. Rerank cùng tập chunks, không thêm hoặc xóa chunk.
5. Tính lại hai metrics và giải thích kết quả.

| ID | Recall before | Recall after | Precision before | Precision after | Delta Precision |
|---|---:|---:|---:|---:|---:|
| | | | | | |
| | | | | | |
| | | | | | |
| | | | | | |
| | | | | | |
| **Avg** | | | | | |

**Tại sao Recall dự kiến không đổi?**

> *Câu trả lời:*

**Khi nào reranking không đủ và cần sửa retriever/query/chunking?**

> *Câu trả lời:*

---

## Part 4 — Reflection (11:35–11:50)

Hoàn thành `reflection.md` bằng kết quả thật từ Exercise 3.2.

---

## Completion Checklist

Hoàn thành kiểm tra cuối trong khoảng 11:50–12:00.

- [ ] Tất cả required tests pass.
- [ ] `golden_dataset.json` validate thành công.
- [ ] Exercise 3.1 hoàn thành trong file JSON và bảng kết quả phía trên.
- [ ] Exercise 3.2 có năm metrics, aggregate report và ba cases thấp nhất.
- [ ] Exercise 3.3 có rubric 1–5 và bias controls.
- [ ] `reflection.md` có ba failure analyses và regression strategy.
- [ ] Đã copy `template.py` thành `solution/solution.py`.
- [ ] Exercise 3.4 và 3.5 chỉ làm nếu chọn bonus.
