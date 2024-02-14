# The Documentation OWASP


OWASP TOP10을 정리해보자.
{{&lt; figure src=&#34;/images/owasp/1-1.png&#34; title=&#34;owasp top10 출처:OWASP&#34; &gt;}}


|  | Name | 설명 |
| :-: | - | - | 
| A01 | Broken Access Control | Moving up from the fifth position, 94% of applications were tested for some form of broken access control with the average incidence rate of 3.81%, and has the most occurrences in the contributed dataset with over 318k. Notable Common Weakness Enumerations (CWEs) included are CWE-200: Exposure of Sensitive Information to an Unauthorized Actor, CWE-201: Exposure of Sensitive Information Through Sent Data, and CWE-352: Cross-Site Request Forgery. |
| A02 | Cryptographic Failures | Shifting up one position to #2, previously known as Sensitive Data Exposure, which is more of a broad symptom rather than a root cause, the focus is on failures related to cryptography (or lack thereof). Which often lead to exposure of sensitive data. Notable Common Weakness Enumerations (CWEs) included are CWE-259: Use of Hard-coded Password, CWE-327: Broken or Risky Crypto Algorithm, and CWE-331 Insufficient Entropy . |
| A03 | Injection | Injection slides down to the third position. 94% of the applications were tested for some form of injection with a max incidence rate of 19%, an average incidence rate of 3%, and 274k occurances. Notable Common Weakness Enumerations (CWEs) included are CWE-79: Cross-site Scripting, CWE-89: SQL Injection, and CWE-73: External Control of File Name or Path. |
| A04 | Insecure Design | A new category for 2021 focuses on risks related to design and architectural flaws, with a call for more use of threat modeling, secure design patterns, and reference architectures. As a community we need to move beyond &#34;shift-left&#34; in the coding space to pre-code activities that are critical for the principles of Secure by Design. Notable Common Weakness Enumerations (CWEs) include CWE-209: Generation of Error Message Containing Sensitive Information, CWE-256: Unprotected Storage of Credentials, CWE-501: Trust Boundary Violation, and CWE-522: Insufficiently Protected Credentials. |
| A05 | Security Misconfiguration | Moving up from #6 in the previous edition, 90% of applications were tested for some form of misconfiguration, with an average incidence rate of 4.%, and over 208k occurences of a Common Weakness Enumeration (CWE) in this risk category. With more shifts into highly configurable software, it&#39;s not surprising to see this category move up. Notable CWEs included are CWE-16 Configuration and CWE-611 Improper Restriction of XML External Entity Reference. |
| A06 | Vulnerable and Outdated Components | It was #2 from the Top 10 community survey but also had enough data to make the Top 10 via data. Vulnerable Components are a known issue that we struggle to test and assess risk and is the only category to not have any Common Weakness Enumerations (CWEs) mapped to the included CWEs, so a default exploits/impact weight of 5.0 is used. Notable CWEs included are CWE-1104: Use of Unmaintained Third-Party Components and the two CWEs from Top 10 2013 and 2017. |
| A07 | Identification and Authentication Failures | Previously known as Broken Authentication, this category slid down from the second position and now includes Common Weakness Enumerations (CWEs) related to identification failures. Notable CWEs included are CWE-297: Improper Validation of Certificate with Host Mismatch, CWE-287: Improper Authentication, and CWE-384: Session Fixation |
| A08 | Software and Data Integrity Failures | A new category for 2021 focuses on making assumptions related to software updates, critical data, and CI/CD pipelines without verifying integrity. One of the highest weighted impacts from Common Vulnerability and Exposures/Common Vulnerability Scoring System (CVE/CVSS) data. Notable Common Weakness Enumerations (CWEs) include CWE-829: Inclusion of Functionality from Untrusted Control Sphere, CWE-494: Download of Code Without Integrity Check, and CWE-502: Deserialization of Untrusted Data. |
| A09 | Security Logging and Monitoring Failures | Security logging and monitoring came from the Top 10 community survey (#3), up slightly from the tenth position in the OWASP Top 10 2017. Logging and monitoring can be challenging to test, often involving interviews or asking if attacks were detected during a penetration test. There isn&#39;t much CVE/CVSS data for this category, but detecting and responding to breaches is critical. Still, it can be very impactful for accountability, visibility, incident alerting, and forensics. This category expands beyond CWE-778 Insufficient Logging to include CWE-117 Improper Output Neutralization for Logs, CWE-223 Omission of Security-relevant Information, and CWE-532 Insertion of Sensitive Information into Log File. |
| A10 | Server-Side Request Forgery (SSRF) | This category is added from the Top 10 community survey (#1). The data shows a relatively low incidence rate with above average testing coverage and above-average Exploit and Impact potential ratings. As new entries are likely to be a single or small cluster of Common Weakness Enumerations (CWEs) for attention and awareness, the hope is that they are subject to focus and can be rolled into a larger category in a future edition. |


## A01 Broken Access Control
| CWEs Mapped | Max Incidence Rate | Avg Incidence Rate | Avg Weighted Exploit| Avg Weighted Impact | Max Coverage | Avg Coverage | Total Occurrences | Total CVEs |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| 34 | 55.97% | 3.81% | 6.92 | 5.93 | 94.55% | 47.72% | 318,487 | 19,013 |

#### 설명
액세스 제어는 사용자가 의도한 권한을 벗어나 행동할 수 없도록 정책을 시행합니다. 실패는 일반적으로 모든 데이터의 무단 정보 공개, 수정 또는 파괴로 이어지거나 사용자의 한계를 벗어난 비즈니스 기능을 수행하게 됩니다. 일반적인 액세스 제어 취약점은 다음과 같습니다.

* 특정 기능, 역할 또는 사용자에게만 액세스 권한을 부여해야 하지만 누구나 사용할 수 있는 최소 권한 또는 기본 거부 원칙 위반입니다.

* URL(매개변수 변조 또는 강제 탐색), 내부 애플리케이션 상태 또는 HTML 페이지를 수정하거나 API 요청을 수정하는 공격 도구를 사용하여 액세스 제어 검사를 우회합니다.

* 고유 식별자를 제공하여 다른 사람의 계정 보기 또는 편집 허용(안전하지 않은 직접 개체 참조)

* POST, PUT 및 DELETE에 대한 액세스 제어가 누락된 API 액세스.

* 특권 상승. 로그인하지 않고 사용자로 활동하거나 사용자로 로그인하면 관리자로 활동합니다.

* JSON 웹 토큰(JWT) 액세스 제어 토큰 재생 또는 변조, 권한 상승을 위해 조작된 쿠키 또는 숨겨진 필드, JWT 무효화 남용과 같은 메타데이터 조작.

* CORS 구성이 잘못되면 승인되지 않은/신뢰할 수 없는 출처의 API 액세스가 허용됩니다.

* 인증되지 않은 사용자로 인증된 페이지를 강제로 탐색하거나 표준 사용자로 권한 있는 페이지를 탐색합니다.

## A02 Cryptographic Failures
| CWEs Mapped | Max Incidence Rate | Avg Incidence Rate | Avg Weighted Exploit| Avg Weighted Impact | Max Coverage | Avg Coverage | Total Occurrences | Total CVEs |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| 29 | 46.44% | 4.49% | 7.29 | 6.81 | 79.33% | 34.85% | 233,788 | 3,075 |

#### 설명
첫 번째는 전송 중인 데이터와 저장되지 않은 데이터의 보호 요구 사항을 결정하는 것입니다. 예를 들어 암호, 신용 카드 번호, 건강 기록, 개인 정보 및 비즈니스 비밀은 주로 해당 데이터가 개인 정보 보호법(예: EU의 일반 데이터 보호 규정(GDPR) 또는 규정(예: 금융 데이터 보호)에 해당하는 경우 추가 보호가 필요합니다. PCI 데이터 보안 표준(PCI DSS)과 같은. 이러한 모든 데이터의 경우:

* 데이터가 일반 텍스트로 전송됩니까? 이는 STARTTLS와 같은 TLS 업그레이드도 사용하는 HTTP, SMTP, FTP와 같은 프로토콜과 관련이 있습니다. 외부 인터넷 트래픽은 위험합니다. 로드 밸런서, 웹 서버 또는 백엔드 시스템 간의 모든 내부 트래픽을 확인합니다.
 
* 기본적으로 또는 이전 코드에서 사용되는 오래되거나 약한 암호화 알고리즘이나 프로토콜이 있습니까?
 
* 기본 암호화 키가 사용 중이거나 약한 암호화 키가 생성 또는 재사용되거나 적절한 키 관리 또는 순환이 누락되었습니까? 암호화 키는 소스 코드 저장소에 체크인됩니까?
 
* 암호화가 시행되지 않습니까? 예를 들어 HTTP 헤더(브라우저) 보안 지시문이나 헤더가 누락되었습니까?
 
* 수신한 서버 인증서와 신뢰 체인이 제대로 검증되었습니까?
 
* 초기화 벡터가 무시, 재사용 또는 생성된 암호화 작동 모드에 대해 충분히 안전하지 않습니까? ECB와 같은 안전하지 않은 작동 모드가 사용 중입니까? 인증된 암호화가 더 적절할 때 암호화가 사용됩니까?
 
* 암호 기반 키 파생 기능이 없는 경우 암호가 암호 키로 사용됩니까?
 
* 암호화 요구 사항을 충족하도록 설계되지 않은 암호화 목적에 무작위성이 사용됩니까? 올바른 기능을 선택하더라도 개발자가 시드해야 합니까? 그렇지 않은 경우 개발자가 엔트로피/예측 불가능성이 부족한 시드로 내장된 강력한 시딩 기능을 덮어썼습니까?
 
* MD5 또는 SHA1과 같은 더 이상 사용되지 않는 해시 함수가 사용 중이거나 암호화 해시 함수가 필요할 때 비암호화 해시 함수가 사용됩니까?
 
* PKCS 번호 1 v1.5와 같은 더 이상 사용되지 않는 암호화 패딩 방법이 사용 중입니까?

* 예를 들어 패딩 오라클 공격의 형태로 암호화 오류 메시지 또는 부채널 정보가 악용될 수 있습니까?

## A03 Injection
| CWEs Mapped | Max Incidence Rate | Avg Incidence Rate | Avg Weighted Exploit| Avg Weighted Impact | Max Coverage | Avg Coverage | Total Occurrences | Total CVEs |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| 33 | 19.09% | 3.37% | 7.25 | 7.15 | 94.04% | 47.90% | 274,228 | 32,078 |

#### 설명
애플리케이션은 다음과 같은 경우 공격에 취약합니다.

* 사용자 제공 데이터는 애플리케이션에서 검증, 필터링 또는 삭제되지 않습니다.
* 컨텍스트 인식 이스케이프가 없는 동적 쿼리 또는 매개변수화되지 않은 호출은 인터프리터에서 직접 사용됩니다.
* 적대적인 데이터는 ORM(객체 관계형 매핑) 검색 매개변수 내에서 사용되어 중요한 추가 레코드를 추출합니다.
* 적대적인 데이터를 직접 사용하거나 연결합니다. SQL 또는 명령은 동적 쿼리, 명령 또는 저장 프로시저의 구조 및 악성 데이터를 포함합니다.
* 더 일반적인 주입에는 SQL, NoSQL, OS 명령, ORM(Object Relational Mapping), LDAP 및 EL(Expression Language) 또는 OGNL(Object Graph Navigation Library) 주입이 있습니다. 개념은 모든 통역사 간에 동일합니다. 소스 코드 검토는 애플리케이션이 주입에 취약한지 감지하는 가장 좋은 방법입니다. 모든 매개변수, 헤더, URL, 쿠키, JSON, SOAP 및 XML 데이터 입력에 대한 자동 테스트를 적극 권장합니다. 조직은 CI/CD 파이프라인에 정적(SAST), 동적(DAST) 및 대화형(IAST) 애플리케이션 보안 테스트 도구를 포함하여 프로덕션 배포 전에 도입된 주입 결함을 식별할 수 있습니다.


## A04 Insecure Design
| CWEs Mapped | Max Incidence Rate | Avg Incidence Rate | Avg Weighted Exploit| Avg Weighted Impact | Max Coverage | Avg Coverage | Total Occurrences | Total CVEs |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| 40 | 24.19% | 3.00% | 6.46 | 6.78 | 77.25% | 42.51% | 262,407 | 2,691 |

#### 설명
안전하지 않은 설계는 &#34;누락되거나 비효율적인 제어 설계&#34;로 표현되는 다양한 약점을 나타내는 광범위한 범주입니다. 안전하지 않은 디자인은 다른 모든 상위 10개 위험 범주의 원인이 아닙니다. 안전하지 않은 설계와 안전하지 않은 구현에는 차이가 있습니다. 우리는 근본 원인과 해결 방법이 다르기 때문에 설계 결함과 구현 결함을 구별합니다. 보안 설계에는 여전히 악용될 수 있는 취약점으로 이어지는 구현 결함이 있을 수 있습니다. 안전하지 않은 설계는 정의상 특정 공격을 방어하기 위해 필요한 보안 제어가 생성되지 않았기 때문에 완벽한 구현으로 수정할 수 없습니다. 안전하지 않은 설계에 기여하는 요인 중 하나는 개발 중인 소프트웨어 또는 시스템에 내재된 비즈니스 위험 프로파일링의 부족입니다.

## A05 Security Misconfiguration
| CWEs Mapped | Max Incidence Rate | Avg Incidence Rate | Avg Weighted Exploit| Avg Weighted Impact | Max Coverage | Avg Coverage | Total Occurrences | Total CVEs |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| 20 | 19.84% | 4.51% | 8.12 | 6.56 | 89.58% | 44.84% | 208,387 | 789 |

#### 설명

애플리케이션이 다음과 같은 경우 취약할 수 있습니다.

* 애플리케이션 스택의 모든 부분에서 적절한 보안 강화가 누락되었거나 클라우드 서비스에 대한 권한이 부적절하게 구성되었습니다.
* 불필요한 기능이 활성화되거나 설치됩니다(예: 불필요한 포트, 서비스, 페이지, 계정 또는 권한).
* 기본 계정과 해당 암호는 여전히 활성화되어 있으며 변경되지 않습니다.
* 오류 처리는 스택 추적 또는 기타 지나치게 유익한 오류 메시지를 사용자에게 보여줍니다.
* 업그레이드된 시스템의 경우 최신 보안 기능이 비활성화되거나 안전하게 구성되지 않습니다.
* 애플리케이션 서버, 애플리케이션 프레임워크(예: Struts, Spring, ASP.NET), 라이브러리, 데이터베이스 등의 보안 설정이 보안 값으로 설정되어 있지 않습니다.
* 서버가 보안 헤더 또는 지시문을 보내지 않거나 보안 값으로 설정되지 않았습니다.
* 소프트웨어가 오래되었거나 취약합니다( A06:2021-Vulnerable and Outdated Components 참조).

일관되고 반복 가능한 애플리케이션 보안 구성 프로세스가 없으면 시스템이 더 큰 위험에 노출됩니다.

## A06 Vulnerable and Outdated Components
| CWEs Mapped | Max Incidence Rate | Avg Incidence Rate | Avg Weighted Exploit| Avg Weighted Impact | Max Coverage | Avg Coverage | Total Occurrences | Total CVEs |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| 3 | 27.96% | 8.77% | 51.78% | 22.47% | 5.00 | 5.00 | 30,457 | 0 |

#### 설명
당신은 취약할 가능성이 있습니다:

* 사용하는 모든 구성 요소(클라이언트 측 및 서버 측 모두)의 버전을 모르는 경우. 여기에는 직접 사용하는 구성 요소와 중첩된 종속성이 포함됩니다.
* 소프트웨어가 취약하거나 지원되지 않거나 오래된 경우. 여기에는 OS, 웹/애플리케이션 서버, 데이터베이스 관리 시스템(DBMS), 애플리케이션, API 및 모든 구성 요소, 런타임 환경 및 라이브러리가 포함됩니다.
* 취약점을 정기적으로 스캔하지 않고 사용하는 구성 요소와 관련된 보안 게시판을 구독하지 않는 경우.
* 위험 기반의 적시에 기본 플랫폼, 프레임워크 및 종속성을 수정하거나 업그레이드하지 않는 경우. 이는 패치가 변경 통제 하에 있는 월별 또는 분기별 작업인 환경에서 일반적으로 발생하여 조직이 수정된 취약점에 며칠 또는 몇 달 동안 불필요하게 노출될 수 있습니다.
* 소프트웨어 개발자가 업데이트, 업그레이드 또는 패치된 라이브러리의 호환성을 테스트하지 않는 경우.
* 구성 요소의 구성을 보호하지 않는 경우(A05:2021-Security Misconfiguration 참조).

## A07 Identification and Authentication Failures

| CWEs Mapped | Max Incidence Rate | Avg Incidence Rate | Avg Weighted Exploit| Avg Weighted Impact | Max Coverage | Avg Coverage | Total Occurrences | Total CVEs |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| 22 | 14.84% | 2.55% | 7.40 | 6.50 | 79.51% | 45.72% | 132,195 | 3,897 |

#### 설명
사용자의 신원 확인, 인증 및 세션 관리는 인증 관련 공격으로부터 보호하는 데 중요합니다. 애플리케이션이 다음과 같은 경우 인증 취약점이 있을 수 있습니다.

* 공격자가 유효한 사용자 이름 및 암호 목록을 가지고 있는 경우 자격 증명 스터핑과 같은 자동화된 공격을 허용합니다.
* 무차별 대입 또는 기타 자동화된 공격을 허용합니다.
* &#34;Password1&#34; 또는 &#34;admin/admin&#34;과 같은 기본 암호, 취약하거나 잘 알려진 암호를 허용합니다.
* 안전할 수 없는 &#34;지식 기반 답변&#34;과 같은 취약하거나 비효율적인 자격 증명 복구 및 비밀번호 찾기 프로세스를 사용합니다.
* 일반 텍스트, 암호화되거나 약하게 해시된 암호 데이터 저장소를 사용합니다( A02:2021-Cryptographic Failures 참조).
* 다단계 인증이 없거나 비효율적입니다.
* URL의 세션 식별자를 노출합니다.
* 로그인 성공 후 세션 식별자를 재사용합니다.
* 세션 ID를 올바르게 무효화하지 않습니다. 사용자 세션 또는 인증 토큰(주로 SSO(Single Sign-On) 토큰)은 로그아웃 또는 비활성 기간 동안 제대로 무효화되지 않습니다.

## A08 Software and Data Integrity Failures

| CWEs Mapped | Max Incidence Rate | Avg Incidence Rate | Avg Weighted Exploit| Avg Weighted Impact | Max Coverage | Avg Coverage | Total Occurrences | Total CVEs |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| 10 | 16.67% | 2.05% | 6.94 | 7.94 | 75.04% | 45.35% | 47,972 | 1,152 |

#### 설명
소프트웨어 및 데이터 무결성 오류는 무결성 위반으로부터 보호하지 않는 코드 및 인프라와 관련됩니다. 이에 대한 예는 애플리케이션이 신뢰할 수 없는 소스, 저장소 및 CDN(콘텐츠 전달 네트워크)의 플러그인, 라이브러리 또는 모듈에 의존하는 경우입니다. 안전하지 않은 CI/CD 파이프라인은 무단 액세스, 악성 코드 또는 시스템 손상의 가능성을 유발할 수 있습니다. 마지막으로, 많은 응용 프로그램에는 이제 충분한 무결성 확인 없이 업데이트가 다운로드되고 이전에 신뢰했던 응용 프로그램에 적용되는 자동 업데이트 기능이 포함됩니다. 공격자는 잠재적으로 자신의 업데이트를 업로드하여 배포하고 모든 설치에서 실행할 수 있습니다. 또 다른 예는 공격자가 보고 수정할 수 있는 구조로 개체 또는 데이터가 인코딩되거나 직렬화되어 안전하지 않은 역직렬화에 취약한 경우입니다.

## A09 Security Logging and Monitoring Failures

| CWEs Mapped | Max Incidence Rate | Avg Incidence Rate | Avg Weighted Exploit| Avg Weighted Impact | Max Coverage | Avg Coverage | Total Occurrences | Total CVEs |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| 4 | 19.23% | 6.51% | 6.87 | 4.99 | 53.67% | 39.97% | 53,615 | 242 |

#### 설명
OWASP Top 10 2021로 돌아가서 이 카테고리는 활성 침해를 감지, 에스컬레이션 및 대응하는 데 도움이 됩니다. 로깅 및 모니터링 없이는 위반을 감지할 수 없습니다. 불충분한 로깅, 탐지, 모니터링 및 활성 응답은 다음과 같은 경우에 발생합니다.

* 로그인, 로그인 실패 및 가치가 높은 트랜잭션과 같은 감사 가능한 이벤트는 기록되지 않습니다.
* 경고 및 오류는 아니오, 부적절하거나 불명확한 로그 메시지를 생성합니다.
* 애플리케이션 및 API 로그는 의심스러운 활동에 대해 모니터링되지 않습니다.
* 로그는 로컬에만 저장됩니다.
* 적절한 경고 임계값 및 응답 에스컬레이션 프로세스가 적절하지 않거나 효과적이지 않습니다.
* DAST(동적 애플리케이션 보안 테스트) 도구(예: OWASP ZAP)에 의한 침투 테스트 및 스캔은 경고를 트리거하지 않습니다.
* 애플리케이션은 실시간 또는 거의 실시간으로 활성 공격을 감지, 확대 또는 경고할 수 없습니다.

사용자나 공격자가 볼 수 있는 로깅 및 경고 이벤트를 통해 정보 유출에 취약합니다( A01:2021-Broken Access Control 참조).

## A10 Server-Side Request Forgery (SSRF)

| CWEs Mapped | Max Incidence Rate | Avg Incidence Rate | Avg Weighted Exploit| Avg Weighted Impact | Max Coverage | Avg Coverage | Total Occurrences | Total CVEs |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| 1 | 2.72% | 2.72% | 8.28 | 6.72 | 67.72% | 67.72% | 9,503 | 385 |

#### 설명

SSRF 결함은 웹 애플리케이션이 사용자가 제공한 URL의 유효성을 검사하지 않고 원격 리소스를 가져올 때마다 발생합니다. 이를 통해 공격자는 방화벽, VPN 또는 다른 유형의 네트워크 ACL(액세스 제어 목록)에 의해 보호되는 경우에도 응용 프로그램이 조작된 요청을 예기치 않은 대상으로 보내도록 강제할 수 있습니다.

최신 웹 애플리케이션이 최종 사용자에게 편리한 기능을 제공함에 따라 URL 가져오기가 일반적인 시나리오가 되었습니다. 그 결과 SSRF의 발병률이 증가하고 있습니다. 또한 클라우드 서비스와 아키텍처의 복잡성으로 인해 SSRF의 심각도가 높아지고 있습니다.


[&lt;i class=&#34;fas fa-link&#34;&gt;&lt;/i&gt; 자료출처: OWASP](https://owasp.org/Top10/)


---

> Author: Dokyung  
> URL: https://huntedhappy.github.io/ko/owsap/  

